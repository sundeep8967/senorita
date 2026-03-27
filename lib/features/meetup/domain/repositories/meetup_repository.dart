import '../models/meetup_model.dart';

abstract class MeetupRepository {
  /// Creates a new meetup record.
  /// Returns the ID of the newly created meetup.
  Future<String> createMeetup(Meetup meetup);

  /// Updates the status of an existing meetup.
  Future<void> updateMeetupStatus(String meetupId, MeetupStatus status);

  /// Retrieves the details of a specific meetup.
  Future<Meetup?> getMeetupDetails(String meetupId);

  /// Retrieves a stream of meetups for a given user.
  Stream<List<Meetup>> getMeetupsForUser(String userId);
}
