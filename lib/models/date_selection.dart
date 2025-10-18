import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DateSelection {
  final String id;
  final String userId;
  final String chatRoomId;
  final List<DateTime> selectedDates;
  final String gender; // 'male' or 'female'
  final Timestamp createdAt;
  final Timestamp updatedAt;

  DateSelection({
    required this.id,
    required this.userId,
    required this.chatRoomId,
    required this.selectedDates,
    required this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DateSelection.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DateSelection(
      id: doc.id,
      userId: data['userId'] ?? '',
      chatRoomId: data['chatRoomId'] ?? '',
      selectedDates: (data['selectedDates'] as List<dynamic>?)
              ?.map((timestamp) => (timestamp as Timestamp).toDate())
              .toList() ??
          [],
      gender: data['gender'] ?? 'male',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'chatRoomId': chatRoomId,
      'selectedDates': selectedDates.map((date) => Timestamp.fromDate(date)).toList(),
      'gender': gender,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  DateSelection copyWith({
    String? id,
    String? userId,
    String? chatRoomId,
    List<DateTime>? selectedDates,
    String? gender,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return DateSelection(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      selectedDates: selectedDates ?? this.selectedDates,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MatchedDate {
  final DateTime date;
  final TimeOfDay? girlTime;
  final TimeOfDay? boyTime;
  final bool isConfirmed;

  MatchedDate({
    required this.date,
    this.girlTime,
    this.boyTime,
    this.isConfirmed = false,
  });

  factory MatchedDate.fromMap(Map<String, dynamic> data) {
    return MatchedDate(
      date: (data['date'] as Timestamp).toDate(),
      girlTime: data['girlTime'] != null
          ? TimeOfDay(
              hour: data['girlTime']['hour'],
              minute: data['girlTime']['minute'],
            )
          : null,
      boyTime: data['boyTime'] != null
          ? TimeOfDay(
              hour: data['boyTime']['hour'],
              minute: data['boyTime']['minute'],
            )
          : null,
      isConfirmed: data['isConfirmed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'girlTime': girlTime != null
          ? {'hour': girlTime!.hour, 'minute': girlTime!.minute}
          : null,
      'boyTime': boyTime != null
          ? {'hour': boyTime!.hour, 'minute': boyTime!.minute}
          : null,
      'isConfirmed': isConfirmed,
    };
  }
}

class MeetupSchedule {
  final String id;
  final String chatRoomId;
  final List<String> participantIds;
  final List<MatchedDate> matchedDates;
  final String? boyVerificationCode; // 3-char code for boy
  final String? girlVerificationCode; // 3-char code for girl
  final Timestamp? acceptedAt; // When meetup was accepted
  final Timestamp? selectionDeadline; // 2 days from acceptance
  final bool isAbandoned; // If deadline passed without date selection
  final Timestamp createdAt;
  final Timestamp updatedAt;

  MeetupSchedule({
    required this.id,
    required this.chatRoomId,
    required this.participantIds,
    required this.matchedDates,
    this.boyVerificationCode,
    this.girlVerificationCode,
    this.acceptedAt,
    this.selectionDeadline,
    this.isAbandoned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MeetupSchedule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MeetupSchedule(
      id: doc.id,
      chatRoomId: data['chatRoomId'] ?? '',
      participantIds: List<String>.from(data['participantIds'] ?? []),
      matchedDates: (data['matchedDates'] as List<dynamic>?)
              ?.map((item) => MatchedDate.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      boyVerificationCode: data['boyVerificationCode'],
      girlVerificationCode: data['girlVerificationCode'],
      acceptedAt: data['acceptedAt'],
      selectionDeadline: data['selectionDeadline'],
      isAbandoned: data['isAbandoned'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatRoomId': chatRoomId,
      'participantIds': participantIds,
      'matchedDates': matchedDates.map((md) => md.toMap()).toList(),
      'boyVerificationCode': boyVerificationCode,
      'girlVerificationCode': girlVerificationCode,
      'acceptedAt': acceptedAt,
      'selectionDeadline': selectionDeadline,
      'isAbandoned': isAbandoned,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
