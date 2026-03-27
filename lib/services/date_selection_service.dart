import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/date_selection.dart';
import '../models/meetup_rating.dart';
import '../models/app_notification.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/app_notification_service.dart';

class DateSelectionService {
  static final DateSelectionService _instance = DateSelectionService._internal();
  factory DateSelectionService() => _instance;
  DateSelectionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();
  final AppNotificationService _appNotificationService = AppNotificationService();

  /// Generate a random 3-character alphanumeric code
  String _generateVerificationCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Excluding confusing chars
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(3, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  /// Get or create date selection document for a user in a chat
  Future<DateSelection?> getDateSelection(String chatRoomId, String userId) async {
    try {
      final docId = '${chatRoomId}_$userId';
      final doc = await _firestore.collection('date_selections').doc(docId).get();

      if (doc.exists) {
        return DateSelection.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting date selection: $e');
      return null;
    }
  }

  /// Save or update date selection
  Future<void> saveDateSelection({
    required String chatRoomId,
    required String userId,
    required List<DateTime> selectedDates,
    required String gender,
  }) async {
    try {
      final docId = '${chatRoomId}_$userId';
      final now = Timestamp.now();

      // Check if document exists
      final existingDoc = await _firestore.collection('date_selections').doc(docId).get();

      if (existingDoc.exists) {
        // Update existing
        await _firestore.collection('date_selections').doc(docId).update({
          'selectedDates': selectedDates.map((date) => Timestamp.fromDate(date)).toList(),
          'updatedAt': now,
        });
      } else {
        // Create new
        final dateSelection = DateSelection(
          id: docId,
          userId: userId,
          chatRoomId: chatRoomId,
          selectedDates: selectedDates,
          gender: gender,
          createdAt: now,
          updatedAt: now,
        );

        await _firestore
            .collection('date_selections')
            .doc(docId)
            .set(dateSelection.toFirestore());
      }

      print('✅ Date selection saved for user: $userId');

      // Send notification to other user about date selection
      await _notifyOtherUserOfDateSelection(chatRoomId, userId, selectedDates.length);

      // Check for overlapping dates and create matched dates
      await _checkAndCreateMatchedDates(chatRoomId);
    } catch (e) {
      print('❌ Error saving date selection: $e');
      rethrow;
    }
  }

  /// Stream date selections for a chat room
  Stream<List<DateSelection>> streamDateSelections(String chatRoomId) {
    return _firestore
        .collection('date_selections')
        .where('chatRoomId', isEqualTo: chatRoomId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => DateSelection.fromFirestore(doc)).toList();
    });
  }

  /// Check for overlapping dates and create matched dates
  Future<void> _checkAndCreateMatchedDates(String chatRoomId) async {
    try {
      // Get both users' date selections
      final selections = await _firestore
          .collection('date_selections')
          .where('chatRoomId', isEqualTo: chatRoomId)
          .get();

      if (selections.docs.length < 2) {
        print('⏳ Waiting for both users to select dates');
        return;
      }

      final dateSelections = selections.docs.map((doc) => DateSelection.fromFirestore(doc)).toList();

      if (dateSelections.length != 2) return;

      final user1Dates = dateSelections[0].selectedDates;
      final user2Dates = dateSelections[1].selectedDates;

      // Find overlapping dates (normalize to date only, ignore time)
      final overlappingDates = <DateTime>[];
      for (final date1 in user1Dates) {
        final normalizedDate1 = DateTime(date1.year, date1.month, date1.day);
        for (final date2 in user2Dates) {
          final normalizedDate2 = DateTime(date2.year, date2.month, date2.day);
          if (normalizedDate1.isAtSameMomentAs(normalizedDate2) &&
              !overlappingDates.any((d) =>
                  d.year == normalizedDate1.year &&
                  d.month == normalizedDate1.month &&
                  d.day == normalizedDate1.day)) {
            overlappingDates.add(normalizedDate1);
          }
        }
      }

      if (overlappingDates.isEmpty) {
        print('ℹ️ No overlapping dates found');
        return;
      }

      print('✅ Found ${overlappingDates.length} overlapping dates');

      // Notify both users about matched dates
      await _notifyUsersOfMatchedDates(
        chatRoomId,
        dateSelections,
        overlappingDates.length,
      );

      // Get existing schedule or create new
      final scheduleDoc = await _firestore.collection('meetup_schedules').doc(chatRoomId).get();

      final now = Timestamp.now();
      final matchedDates = overlappingDates.map((date) => MatchedDate(date: date)).toList();

      if (scheduleDoc.exists) {
        // Update existing
        await _firestore.collection('meetup_schedules').doc(chatRoomId).update({
          'matchedDates': matchedDates.map((md) => md.toMap()).toList(),
          'updatedAt': now,
        });
      } else {
        // Create new
        final schedule = MeetupSchedule(
          id: chatRoomId,
          chatRoomId: chatRoomId,
          participantIds: dateSelections.map((ds) => ds.userId).toList(),
          matchedDates: matchedDates,
          createdAt: now,
          updatedAt: now,
        );

        await _firestore
            .collection('meetup_schedules')
            .doc(chatRoomId)
            .set(schedule.toFirestore());
      }

      print('✅ Matched dates saved to Firestore');
    } catch (e) {
      print('❌ Error checking matched dates: $e');
    }
  }

  /// Get meetup schedule for a chat room
  Future<MeetupSchedule?> getMeetupSchedule(String chatRoomId) async {
    try {
      final doc = await _firestore.collection('meetup_schedules').doc(chatRoomId).get();

      if (doc.exists) {
        return MeetupSchedule.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting meetup schedule: $e');
      return null;
    }
  }

  /// Stream meetup schedule for a chat room
  Stream<MeetupSchedule?> streamMeetupSchedule(String chatRoomId) {
    return _firestore
        .collection('meetup_schedules')
        .doc(chatRoomId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return MeetupSchedule.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Save time for a matched date
  Future<void> saveTimeForMatchedDate({
    required String chatRoomId,
    required DateTime date,
    required TimeOfDay time,
    required bool isGirl,
  }) async {
    try {
      final schedule = await getMeetupSchedule(chatRoomId);
      if (schedule == null) return;

      // Find the matched date
      final updatedDates = schedule.matchedDates.map((md) {
        final normalizedMd = DateTime(md.date.year, md.date.month, md.date.day);
        final normalizedDate = DateTime(date.year, date.month, date.day);

        if (normalizedMd.isAtSameMomentAs(normalizedDate)) {
          if (isGirl) {
            return MatchedDate(
              date: md.date,
              girlTime: time,
              boyTime: md.boyTime,
              isConfirmed: md.boyTime != null, // Confirm if both times are set
            );
          } else {
            return MatchedDate(
              date: md.date,
              girlTime: md.girlTime,
              boyTime: time,
              isConfirmed: md.girlTime != null, // Confirm if both times are set
            );
          }
        }
        return md;
      }).toList();

      await _firestore.collection('meetup_schedules').doc(chatRoomId).update({
        'matchedDates': updatedDates.map((md) => md.toMap()).toList(),
        'updatedAt': Timestamp.now(),
      });

      print('✅ Time saved for matched date');

      // Notify other user about time selection
      await _notifyOtherUserOfTimeSelection(
        chatRoomId,
        date,
        time,
        isGirl,
      );
    } catch (e) {
      print('❌ Error saving time: $e');
    }
  }

  /// Clear date selections for a user in a chat
  Future<void> clearDateSelection(String chatRoomId, String userId) async {
    try {
      final docId = '${chatRoomId}_$userId';
      await _firestore.collection('date_selections').doc(docId).delete();
      print('✅ Date selection cleared');
    } catch (e) {
      print('❌ Error clearing date selection: $e');
    }
  }

  /// Initialize meetup schedule when meetup is accepted (sets deadline and codes)
  Future<void> initializeMeetupSchedule({
    required String chatRoomId,
    required List<String> participantIds,
    required String boyUserId,
    required String girlUserId,
  }) async {
    try {
      final now = Timestamp.now();
      final deadline = Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 2)),
      );

      final schedule = MeetupSchedule(
        id: chatRoomId,
        chatRoomId: chatRoomId,
        participantIds: participantIds,
        matchedDates: [],
        boyVerificationCode: _generateVerificationCode(),
        girlVerificationCode: _generateVerificationCode(),
        acceptedAt: now,
        selectionDeadline: deadline,
        isAbandoned: false,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('meetup_schedules')
          .doc(chatRoomId)
          .set(schedule.toFirestore());

      print('✅ Meetup schedule initialized with deadline: ${deadline.toDate()}');
      print('   Boy code: ${schedule.boyVerificationCode}');
      print('   Girl code: ${schedule.girlVerificationCode}');
    } catch (e) {
      print('❌ Error initializing meetup schedule: $e');
    }
  }

  /// Check if deadline has passed and mark as abandoned
  Future<void> checkAndHandleDeadline(String chatRoomId) async {
    try {
      final schedule = await getMeetupSchedule(chatRoomId);
      if (schedule == null) return;

      // Skip if already abandoned or has matched dates
      if (schedule.isAbandoned || schedule.matchedDates.isNotEmpty) return;

      // Check if deadline passed
      if (schedule.selectionDeadline != null) {
        final now = DateTime.now();
        final deadline = schedule.selectionDeadline!.toDate();

        if (now.isAfter(deadline)) {
          print('⚠️ Deadline passed! Marking meetup as abandoned');

          // Mark as abandoned
          await _firestore.collection('meetup_schedules').doc(chatRoomId).update({
            'isAbandoned': true,
            'updatedAt': Timestamp.now(),
          });

          // Update reliability scores for both users
          for (final userId in schedule.participantIds) {
            await _updateReliabilityScore(
              userId: userId,
              abandoned: true,
              noShow: false,
              completed: false,
            );
          }

          print('✅ Meetup marked as abandoned, reliability scores updated');
        }
      }
    } catch (e) {
      print('❌ Error checking deadline: $e');
    }
  }

  /// Update user reliability score
  Future<void> _updateReliabilityScore({
    required String userId,
    required bool abandoned,
    required bool noShow,
    required bool completed,
  }) async {
    try {
      final doc = await _firestore.collection('user_reliability').doc(userId).get();

      UserReliabilityScore score;

      if (doc.exists) {
        score = UserReliabilityScore.fromFirestore(doc);
      } else {
        // Create new score
        score = UserReliabilityScore(
          userId: userId,
          totalMeetups: 0,
          completedMeetups: 0,
          abandonedMeetups: 0,
          noShowMeetups: 0,
          averageRating: 5.0,
          reliabilityScore: 100.0,
          updatedAt: Timestamp.now(),
        );
      }

      // Update counts
      final newTotal = score.totalMeetups + 1;
      final newCompleted = completed ? score.completedMeetups + 1 : score.completedMeetups;
      final newAbandoned = abandoned ? score.abandonedMeetups + 1 : score.abandonedMeetups;
      final newNoShow = noShow ? score.noShowMeetups + 1 : score.noShowMeetups;

      // Recalculate score
      final newScore = UserReliabilityScore.calculateScore(
        completed: newCompleted,
        abandoned: newAbandoned,
        noShows: newNoShow,
        avgRating: score.averageRating,
      );

      // Update Firestore
      await _firestore.collection('user_reliability').doc(userId).set({
        'totalMeetups': newTotal,
        'completedMeetups': newCompleted,
        'abandonedMeetups': newAbandoned,
        'noShowMeetups': newNoShow,
        'averageRating': score.averageRating,
        'reliabilityScore': newScore,
        'updatedAt': Timestamp.now(),
      });

      print('✅ Reliability score updated for $userId: $newScore');
    } catch (e) {
      print('❌ Error updating reliability score: $e');
    }
  }

  /// Submit meetup rating after meetup day
  Future<void> submitMeetupRating({
    required String chatRoomId,
    required String raterId,
    required String ratedUserId,
    required DateTime meetupDate,
    required int respectfulnessRating,
    required int punctualityRating,
    required int conversationRating,
    required int overallRating,
    required bool showedUp,
    String? comment,
  }) async {
    try {
      final ratingId = '${chatRoomId}_${raterId}_${meetupDate.millisecondsSinceEpoch}';

      final rating = MeetupRating(
        id: ratingId,
        chatRoomId: chatRoomId,
        raterId: raterId,
        ratedUserId: ratedUserId,
        meetupDate: meetupDate,
        respectfulnessRating: respectfulnessRating,
        punctualityRating: punctualityRating,
        conversationRating: conversationRating,
        overallRating: overallRating,
        comment: comment,
        showedUp: showedUp,
        createdAt: Timestamp.now(),
      );

      await _firestore.collection('meetup_ratings').doc(ratingId).set(rating.toFirestore());

      // Update rated user's reliability score
      await _updateReliabilityScoreWithRating(
        userId: ratedUserId,
        rating: rating,
      );

      print('✅ Rating submitted successfully');
    } catch (e) {
      print('❌ Error submitting rating: $e');
      rethrow;
    }
  }

  /// Update reliability score with rating data
  Future<void> _updateReliabilityScoreWithRating({
    required String userId,
    required MeetupRating rating,
  }) async {
    try {
      final doc = await _firestore.collection('user_reliability').doc(userId).get();

      UserReliabilityScore score;

      if (doc.exists) {
        score = UserReliabilityScore.fromFirestore(doc);
      } else {
        score = UserReliabilityScore(
          userId: userId,
          totalMeetups: 0,
          completedMeetups: 0,
          abandonedMeetups: 0,
          noShowMeetups: 0,
          averageRating: 5.0,
          reliabilityScore: 100.0,
          updatedAt: Timestamp.now(),
        );
      }

      // Get all ratings for this user
      final ratingsQuery = await _firestore
          .collection('meetup_ratings')
          .where('ratedUserId', isEqualTo: userId)
          .get();

      // Calculate new average rating
      double totalRating = 0;
      int ratingCount = 0;
      int noShowCount = score.noShowMeetups;

      for (final ratingDoc in ratingsQuery.docs) {
        final r = MeetupRating.fromFirestore(ratingDoc);
        totalRating += r.overallRating;
        ratingCount++;
        if (!r.showedUp) {
          noShowCount++;
        }
      }

      final avgRating = ratingCount > 0 ? totalRating / ratingCount : 5.0;

      // Update completed if they showed up
      final newCompleted = rating.showedUp
          ? score.completedMeetups + 1
          : score.completedMeetups;

      // Recalculate reliability score
      final newScore = UserReliabilityScore.calculateScore(
        completed: newCompleted,
        abandoned: score.abandonedMeetups,
        noShows: noShowCount,
        avgRating: avgRating,
      );

      await _firestore.collection('user_reliability').doc(userId).set({
        'totalMeetups': score.totalMeetups + 1,
        'completedMeetups': newCompleted,
        'abandonedMeetups': score.abandonedMeetups,
        'noShowMeetups': noShowCount,
        'averageRating': avgRating,
        'reliabilityScore': newScore,
        'updatedAt': Timestamp.now(),
      });

      print('✅ Reliability score updated with rating: $newScore');
    } catch (e) {
      print('❌ Error updating score with rating: $e');
    }
  }

  /// Check if rating is pending for a meetup (next day after meetup)
  Future<bool> isRatingPending({
    required String chatRoomId,
    required String raterId,
    required DateTime meetupDate,
  }) async {
    try {
      final ratingId = '${chatRoomId}_${raterId}_${meetupDate.millisecondsSinceEpoch}';
      final doc = await _firestore.collection('meetup_ratings').doc(ratingId).get();
      return !doc.exists;
    } catch (e) {
      print('❌ Error checking rating status: $e');
      return false;
    }
  }

  /// Get user reliability score
  Future<UserReliabilityScore?> getUserReliabilityScore(String userId) async {
    try {
      final doc = await _firestore.collection('user_reliability').doc(userId).get();
      if (doc.exists) {
        return UserReliabilityScore.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting reliability score: $e');
      return null;
    }
  }

  /// Request date reschedule
  Future<void> requestReschedule({
    required String chatRoomId,
    required String requesterId,
    required DateTime oldDate,
    required DateTime newDate,
  }) async {
    try {
      final rescheduleId = '${chatRoomId}_${oldDate.millisecondsSinceEpoch}';

      await _firestore.collection('reschedule_requests').doc(rescheduleId).set({
        'chatRoomId': chatRoomId,
        'requesterId': requesterId,
        'oldDate': Timestamp.fromDate(oldDate),
        'newDate': Timestamp.fromDate(newDate),
        'status': 'pending', // pending, approved, rejected
        'createdAt': Timestamp.now(),
      });

      print('✅ Reschedule request submitted');
    } catch (e) {
      print('❌ Error requesting reschedule: $e');
      rethrow;
    }
  }

  /// Approve reschedule request
  Future<void> approveReschedule(String rescheduleId) async {
    try {
      final doc = await _firestore.collection('reschedule_requests').doc(rescheduleId).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final chatRoomId = data['chatRoomId'];
      final oldDate = (data['oldDate'] as Timestamp).toDate();
      final newDate = (data['newDate'] as Timestamp).toDate();

      // Update the matched date
      final schedule = await getMeetupSchedule(chatRoomId);
      if (schedule != null) {
        final updatedDates = schedule.matchedDates.map((md) {
          if (md.date.year == oldDate.year &&
              md.date.month == oldDate.month &&
              md.date.day == oldDate.day) {
            return MatchedDate(
              date: newDate,
              girlTime: md.girlTime,
              boyTime: md.boyTime,
              isConfirmed: false, // Reset confirmation
            );
          }
          return md;
        }).toList();

        await _firestore.collection('meetup_schedules').doc(chatRoomId).update({
          'matchedDates': updatedDates.map((md) => md.toMap()).toList(),
          'updatedAt': Timestamp.now(),
        });
      }

      // Mark request as approved
      await _firestore.collection('reschedule_requests').doc(rescheduleId).update({
        'status': 'approved',
        'approvedAt': Timestamp.now(),
      });

      print('✅ Reschedule approved');
    } catch (e) {
      print('❌ Error approving reschedule: $e');
    }
  }

  /// Stream reschedule requests for a chat
  Stream<QuerySnapshot> streamRescheduleRequests(String chatRoomId) {
    return _firestore
        .collection('reschedule_requests')
        .where('chatRoomId', isEqualTo: chatRoomId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // ==================== NOTIFICATION HELPERS ====================

  /// Notify other user when dates are selected
  Future<void> _notifyOtherUserOfDateSelection(
    String chatRoomId,
    String selectorUserId,
    int dateCount,
  ) async {
    try {
      // Get chat room to find other user
      final chatRoom = await _firestore.collection('chat_rooms').doc(chatRoomId).get();
      if (!chatRoom.exists) return;

      final participants = List<String>.from(chatRoom.data()?['participantIds'] ?? []);
      final otherUserId = participants.firstWhere(
        (id) => id != selectorUserId,
        orElse: () => '',
      );

      if (otherUserId.isEmpty) return;

      // Get selector's name
      final selectorDoc = await _firestore.collection('users').doc(selectorUserId).get();
      final selectorName = selectorDoc.data()?['fullName'] ?? 'Someone';

      // Send push notification
      await _notificationService.sendDateSelectionNotification(
        receiverId: otherUserId,
        senderName: selectorName,
        dateCount: dateCount,
        chatRoomId: chatRoomId,
      );

      // Create in-app notification
      await _appNotificationService.createNotification(
        userId: otherUserId,
        title: '📅 Date Selection',
        body: '$selectorName selected $dateCount date${dateCount > 1 ? 's' : ''} for your meetup!',
        type: NotificationType.system,
        data: {'chatRoomId': chatRoomId, 'action': 'open_calendar'},
      );

      print('✅ Date selection notifications sent to $otherUserId');
    } catch (e) {
      print('❌ Error sending date selection notification: $e');
    }
  }

  /// Notify both users when dates match
  Future<void> _notifyUsersOfMatchedDates(
    String chatRoomId,
    List<DateSelection> dateSelections,
    int matchCount,
  ) async {
    try {
      if (dateSelections.length != 2) return;

      final user1Id = dateSelections[0].userId;
      final user2Id = dateSelections[1].userId;

      // Get both users' names
      final user1Doc = await _firestore.collection('users').doc(user1Id).get();
      final user2Doc = await _firestore.collection('users').doc(user2Id).get();

      final user1Name = user1Doc.data()?['fullName'] ?? 'Someone';
      final user2Name = user2Doc.data()?['fullName'] ?? 'Someone';

      // Notify user 1 (push + in-app)
      await _notificationService.sendDateMatchNotification(
        receiverId: user1Id,
        otherUserName: user2Name,
        matchCount: matchCount,
        chatRoomId: chatRoomId,
      );
      await _appNotificationService.createNotification(
        userId: user1Id,
        title: '🎉 Matching Dates!',
        body: 'You and $user2Name are both available on $matchCount date${matchCount > 1 ? 's' : ''}!',
        type: NotificationType.system,
        data: {'chatRoomId': chatRoomId, 'action': 'open_chat'},
      );

      // Notify user 2 (push + in-app)
      await _notificationService.sendDateMatchNotification(
        receiverId: user2Id,
        otherUserName: user1Name,
        matchCount: matchCount,
        chatRoomId: chatRoomId,
      );
      await _appNotificationService.createNotification(
        userId: user2Id,
        title: '🎉 Matching Dates!',
        body: 'You and $user1Name are both available on $matchCount date${matchCount > 1 ? 's' : ''}!',
        type: NotificationType.system,
        data: {'chatRoomId': chatRoomId, 'action': 'open_chat'},
      );

      print('✅ Match notifications sent to both users');
    } catch (e) {
      print('❌ Error sending match notifications: $e');
    }
  }

  /// Notify other user when time is selected
  Future<void> _notifyOtherUserOfTimeSelection(
    String chatRoomId,
    DateTime date,
    TimeOfDay time,
    bool isGirl,
  ) async {
    try {
      final schedule = await getMeetupSchedule(chatRoomId);
      if (schedule == null) return;

      final currentUserId = _firebaseService.currentUserId;
      if (currentUserId == null) return;

      final otherUserId = schedule.participantIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      if (otherUserId.isEmpty) return;

      // Get current user's name
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      final userName = userDoc.data()?['fullName'] ?? 'Someone';

      // Format time and date
      final timeStr = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      final dateStr = '${date.month}/${date.day}';

      // Send push notification
      await _notificationService.sendTimeSelectionNotification(
        receiverId: otherUserId,
        senderName: userName,
        time: timeStr,
        date: dateStr,
        chatRoomId: chatRoomId,
        isGirl: isGirl,
      );

      // Create in-app notification
      final title = isGirl ? '👑 Time Selected' : '⏰ Time Confirmed';
      final body = isGirl 
          ? '$userName chose $timeStr for $dateStr. Pick your time!'
          : '$userName picked $timeStr for $dateStr. Meetup confirmed!';
      
      await _appNotificationService.createNotification(
        userId: otherUserId,
        title: title,
        body: body,
        type: NotificationType.system,
        data: {'chatRoomId': chatRoomId, 'action': 'open_chat'},
      );

      print('✅ Time selection notifications sent to $otherUserId');
    } catch (e) {
      print('❌ Error sending time selection notification: $e');
    }
  }

  /// Send deadline warning notifications (call this periodically or via cron)
  Future<void> checkAndSendDeadlineWarnings() async {
    try {
      final now = DateTime.now();

      // Get all schedules with deadlines approaching
      final schedulesQuery = await _firestore
          .collection('meetup_schedules')
          .where('isAbandoned', isEqualTo: false)
          .get();

      for (final doc in schedulesQuery.docs) {
        final schedule = MeetupSchedule.fromFirestore(doc);

        // Skip if already has matched dates
        if (schedule.matchedDates.isNotEmpty) continue;

        // Check deadline
        if (schedule.selectionDeadline != null) {
          final deadline = schedule.selectionDeadline!.toDate();
          final hoursRemaining = deadline.difference(now).inHours;

          // Send warning at 24h and 6h remaining
          if (hoursRemaining == 24 || hoursRemaining == 6) {
            // Get both users' info
            for (final userId in schedule.participantIds) {
              final otherUserId = schedule.participantIds.firstWhere(
                (id) => id != userId,
                orElse: () => '',
              );

              if (otherUserId.isEmpty) continue;

              final otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();
              final otherUserName = otherUserDoc.data()?['fullName'] ?? 'your match';

              // Send push notification
              await _notificationService.sendDeadlineWarningNotification(
                receiverId: userId,
                otherUserName: otherUserName,
                hoursRemaining: hoursRemaining,
                chatRoomId: schedule.chatRoomId,
              );

              // Create in-app notification
              await _appNotificationService.createNotification(
                userId: userId,
                title: '⚠️ Deadline Warning',
                body: '${hoursRemaining}h left to select dates with $otherUserName!',
                type: NotificationType.system,
                data: {'chatRoomId': schedule.chatRoomId, 'action': 'open_calendar'},
              );
            }

            print('✅ Deadline warnings sent for chatRoom: ${schedule.chatRoomId}');
          }
        }
      }
    } catch (e) {
      print('❌ Error checking deadline warnings: $e');
    }
  }
}
