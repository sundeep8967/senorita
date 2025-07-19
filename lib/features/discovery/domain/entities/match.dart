import 'package:equatable/equatable.dart';
import 'profile.dart';

class Match extends Equatable {
  final String id;
  final Profile profile;
  final DateTime matchedAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool hasUnreadMessages;
  final MatchStatus status;

  const Match({
    required this.id,
    required this.profile,
    required this.matchedAt,
    this.lastMessage,
    this.lastMessageAt,
    this.hasUnreadMessages = false,
    this.status = MatchStatus.active,
  });

  @override
  List<Object?> get props => [
        id,
        profile,
        matchedAt,
        lastMessage,
        lastMessageAt,
        hasUnreadMessages,
        status,
      ];
}

enum MatchStatus { active, expired, blocked, meetupRequested, meetupAccepted }