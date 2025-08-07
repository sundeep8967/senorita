import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/meetup_model.dart';
import '../../domain/repositories/meetup_repository.dart';

class MeetupRepositoryImpl implements MeetupRepository {
  final FirebaseFirestore _firestore;

  MeetupRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
      await _meetups.doc(meetupId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      print('Error updating meetup status: $e');
      rethrow;
    }
  }
}
