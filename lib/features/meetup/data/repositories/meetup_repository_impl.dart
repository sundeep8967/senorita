import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/meetup_model.dart';
import '../../domain/repositories/meetup_repository.dart';
import '../../../../services/firebase_service.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/app_notification_service.dart';

class MeetupRepositoryImpl implements MeetupRepository {
  final FirebaseFirestore _firestore;
  final FirebaseService _firebaseService;
  final NotificationService _notificationService;
  final AppNotificationService _appNotificationService;

  MeetupRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseService? firebaseService,
    NotificationService? notificationService,
    AppNotificationService? appNotificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseService = firebaseService ?? FirebaseService(),
        _notificationService = notificationService ?? NotificationService(),
        _appNotificationService = appNotificationService ?? AppNotificationService();

  CollectionReference get _meetups => _firestore.collection('meetups');

  @override
  Future<String> createMeetup(Meetup meetup) async {
    try {
      // Create the meetup document
      final docRef = await _meetups.add(meetup.toFirestore());
      final meetupId = docRef.id;
      print('✅ Meetup created with ID: $meetupId');
      
      // Create in-app notification for invited user
      try {
        final requesterProfile = await _firestore
            .collection('users')
            .doc(meetup.requestingUserId)
            .get();
        
        if (requesterProfile.exists) {
          final requesterName = requesterProfile.data()?['fullName'] ?? 'Someone';
          
          await _appNotificationService.createMeetupRequestNotification(
            receiverId: meetup.invitedUserId,
            requesterName: requesterName,
            meetupId: meetupId,
          );
          print('✅ In-app notification created for meetup request');
        }
      } catch (notifError) {
        print('⚠️ Error creating in-app notification: $notifError');
        // Don't fail meetup creation if notification fails
      }
      
      return meetupId;
    } catch (e) {
      print('❌ Error creating meetup: $e');
      rethrow;
    }
  }

  @override
  Future<Meetup?> getMeetupDetails(String meetupId) async {
    try {
      final doc = await _meetups.doc(meetupId).get();
      if (doc.exists) {
        return Meetup.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting meetup details: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Meetup>> getMeetupsForUser(String userId) {
    // This query gets meetups where the user is either the requester or the invitee.
    return _meetups
        .where('requestingUserId', isEqualTo: userId)
        .snapshots()
        .asyncMap((requesterSnapshot) async {
      final invitedSnapshot = await _meetups
          .where('invitedUserId', isEqualTo: userId)
          .get();

      final meetups = <String, Meetup>{};

      for (var doc in requesterSnapshot.docs) {
        meetups[doc.id] = Meetup.fromFirestore(doc);
      }
      for (var doc in invitedSnapshot.docs) {
        meetups[doc.id] = Meetup.fromFirestore(doc);
      }

      // Sort meetups: Pending first, then everything else by time
      final sortedMeetups = meetups.values.toList()
        ..sort((a, b) {
          // Pending requests always come first
          final aIsPending = a.status == MeetupStatus.pending;
          final bIsPending = b.status == MeetupStatus.pending;
          
          if (aIsPending && !bIsPending) return -1;
          if (!aIsPending && bIsPending) return 1;
          
          // For everything else, just sort by most recent first
          return b.createdAt.compareTo(a.createdAt);
        });

      return sortedMeetups;
    });
  }

  @override
  Future<void> updateMeetupStatus(String meetupId, MeetupStatus status) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status.toString().split('.').last,
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      
      // Add acceptedAt timestamp when status is accepted
      if (status == MeetupStatus.accepted) {
        updateData['acceptedAt'] = FieldValue.serverTimestamp();
      }
      
      await _meetups.doc(meetupId).update(updateData);
      print('✅ Meetup status updated to: ${status.toString().split('.').last}');
      
      // Automatically create chat room when meetup is accepted
      if (status == MeetupStatus.accepted) {
        print('🎉 Meetup accepted! Creating chat room...');
        try {
          // Get the meetup details to find the participants
          final meetupDoc = await _meetups.doc(meetupId).get();
          if (meetupDoc.exists) {
            final meetup = Meetup.fromFirestore(meetupDoc);
            final currentUserId = _firebaseService.currentUserId;
            
            print('📋 Meetup details:');
            print('   - Requesting user: ${meetup.requestingUserId}');
            print('   - Invited user: ${meetup.invitedUserId}');
            print('   - Current user: $currentUserId');
            
            if (currentUserId != null) {
              // Determine the other user (not the current user)
              final otherUserId = currentUserId == meetup.requestingUserId 
                  ? meetup.invitedUserId 
                  : meetup.requestingUserId;
              
              print('👥 Creating chat between $currentUserId and $otherUserId');
              
              // Create the chat room for this meetup
              final chatRoomId = await _firebaseService.createMeetupChatRoom(otherUserId, meetupId);
              print('✅ Chat room created: $chatRoomId');
              print('💬 Users can now chat with each other');
              
              // Create in-app notification for the other user
              try {
                final accepterProfile = await _firestore
                    .collection('users')
                    .doc(currentUserId)
                    .get();
                
                if (accepterProfile.exists) {
                  final accepterName = accepterProfile.data()?['fullName'] ?? 'Someone';
                  
                  await _appNotificationService.createMeetupAcceptedNotification(
                    receiverId: otherUserId,
                    accepterName: accepterName,
                    meetupId: meetupId,
                  );
                  print('✅ In-app notification created for meetup acceptance');
                }
              } catch (notifError) {
                print('⚠️ Error creating in-app notification: $notifError');
              }
            } else {
              print('❌ No current user ID available');
            }
          } else {
            print('❌ Meetup document not found: $meetupId');
          }
        } catch (chatError) {
          print('⚠️ Error creating chat room for accepted meetup: $chatError');
          print('Stack trace: ${chatError.toString()}');
          // Don't rethrow - meetup acceptance should still succeed even if chat creation fails
        }
      }
    } catch (e) {
      print('❌ Error updating meetup status: $e');
      rethrow;
    }
  }
}
