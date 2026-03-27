import 'package:cloud_firestore/cloud_firestore.dart';

class MeetupRating {
  final String id;
  final String chatRoomId;
  final String raterId; // User giving the rating
  final String ratedUserId; // User being rated
  final DateTime meetupDate;
  final int respectfulnessRating; // 1-5 stars
  final int punctualityRating; // 1-5 stars
  final int conversationRating; // 1-5 stars
  final int overallRating; // 1-5 stars
  final String? comment;
  final bool showedUp; // Did they show up?
  final Timestamp createdAt;

  MeetupRating({
    required this.id,
    required this.chatRoomId,
    required this.raterId,
    required this.ratedUserId,
    required this.meetupDate,
    required this.respectfulnessRating,
    required this.punctualityRating,
    required this.conversationRating,
    required this.overallRating,
    this.comment,
    required this.showedUp,
    required this.createdAt,
  });

  factory MeetupRating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MeetupRating(
      id: doc.id,
      chatRoomId: data['chatRoomId'] ?? '',
      raterId: data['raterId'] ?? '',
      ratedUserId: data['ratedUserId'] ?? '',
      meetupDate: (data['meetupDate'] as Timestamp).toDate(),
      respectfulnessRating: data['respectfulnessRating'] ?? 5,
      punctualityRating: data['punctualityRating'] ?? 5,
      conversationRating: data['conversationRating'] ?? 5,
      overallRating: data['overallRating'] ?? 5,
      comment: data['comment'],
      showedUp: data['showedUp'] ?? true,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatRoomId': chatRoomId,
      'raterId': raterId,
      'ratedUserId': ratedUserId,
      'meetupDate': Timestamp.fromDate(meetupDate),
      'respectfulnessRating': respectfulnessRating,
      'punctualityRating': punctualityRating,
      'conversationRating': conversationRating,
      'overallRating': overallRating,
      'comment': comment,
      'showedUp': showedUp,
      'createdAt': createdAt,
    };
  }

  double get averageRating =>
      (respectfulnessRating + punctualityRating + conversationRating + overallRating) / 4.0;
}

class UserReliabilityScore {
  final String userId;
  final int totalMeetups;
  final int completedMeetups;
  final int abandonedMeetups;
  final int noShowMeetups;
  final double averageRating;
  final double reliabilityScore; // 0-100
  final Timestamp updatedAt;

  UserReliabilityScore({
    required this.userId,
    required this.totalMeetups,
    required this.completedMeetups,
    required this.abandonedMeetups,
    required this.noShowMeetups,
    required this.averageRating,
    required this.reliabilityScore,
    required this.updatedAt,
  });

  factory UserReliabilityScore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserReliabilityScore(
      userId: doc.id,
      totalMeetups: data['totalMeetups'] ?? 0,
      completedMeetups: data['completedMeetups'] ?? 0,
      abandonedMeetups: data['abandonedMeetups'] ?? 0,
      noShowMeetups: data['noShowMeetups'] ?? 0,
      averageRating: (data['averageRating'] ?? 5.0).toDouble(),
      reliabilityScore: (data['reliabilityScore'] ?? 100.0).toDouble(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalMeetups': totalMeetups,
      'completedMeetups': completedMeetups,
      'abandonedMeetups': abandonedMeetups,
      'noShowMeetups': noShowMeetups,
      'averageRating': averageRating,
      'reliabilityScore': reliabilityScore,
      'updatedAt': updatedAt,
    };
  }

  // Calculate reliability score
  // Formula: Base 100 - (abandoned * 10) - (no-shows * 20) + (completed * 5)
  // Plus bonus for high ratings
  static double calculateScore({
    required int completed,
    required int abandoned,
    required int noShows,
    required double avgRating,
  }) {
    double score = 100.0;
    
    // Penalties
    score -= (abandoned * 10); // -10 points per abandonment
    score -= (noShows * 20); // -20 points per no-show
    
    // Bonuses
    score += (completed * 2); // +2 points per completed meetup
    score += ((avgRating - 3.0) * 5); // Bonus for ratings above 3.0
    
    // Clamp between 0-100
    return score.clamp(0.0, 100.0);
  }
}
