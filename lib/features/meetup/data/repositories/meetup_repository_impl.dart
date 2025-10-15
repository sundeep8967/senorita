import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/meetup_model.dart';
import '../../domain/repositories/meetup_repository.dart';
import '../../../../services/firebase_service.dart';

class MeetupRepositoryImpl implements MeetupRepository {
  final FirebaseFirestore _firestore;
  final FirebaseService _firebaseService;

  MeetupRepositoryImpl({FirebaseFirestore? firestore, FirebaseService? firebaseService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseService = firebaseService ?? FirebaseService();

  CollectionReference get _meetups => _firestore.collection('meetups');

  @override
  Future<String> createMeetup(Meetup meetup) async {
    try {
      final docRef = await _meetups.add(meetup.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating meetup: $e');
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

      return meetups.values.toList();
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
              print('✅ Chat room created automatically: $chatRoomId');
              print('💬 Both users should now see each other in their chat list');
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
