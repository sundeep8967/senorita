import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/date_selection.dart';
import '../services/date_selection_service.dart';

class VerificationCodeWidget extends StatelessWidget {
  final String chatRoomId;
  final String currentUserGender;

  const VerificationCodeWidget({
    Key? key,
    required this.chatRoomId,
    required this.currentUserGender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MeetupSchedule?>(
      stream: DateSelectionService().streamMeetupSchedule(chatRoomId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final schedule = snapshot.data!;
        final userCode = currentUserGender.toLowerCase() == 'female'
            ? schedule.girlVerificationCode
            : schedule.boyVerificationCode;

        if (userCode == null) {
          return const SizedBox.shrink();
        }

        // Show deadline warning if approaching
        final showDeadlineWarning = schedule.selectionDeadline != null &&
            schedule.matchedDates.isEmpty &&
            !schedule.isAbandoned;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: (currentUserGender.toLowerCase() == 'female' 
                ? Colors.pink 
                : Colors.blue).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: currentUserGender.toLowerCase() == 'female'
                  ? Colors.pink.withOpacity(0.4)
                  : Colors.blue.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.qr_code_2,
                color: currentUserGender.toLowerCase() == 'female' ? Colors.pink : Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Text(
                'Cafe Code:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: userCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Code copied!'),
                      duration: Duration(seconds: 1),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userCode,
                        style: TextStyle(
                          color: currentUserGender.toLowerCase() == 'female'
                              ? Colors.pink
                              : Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.copy,
                        color: Colors.white.withOpacity(0.6),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (showDeadlineWarning)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.orange,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getDeadlineWarningText(schedule.selectionDeadline!),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getDeadlineWarningText(Timestamp deadline) {
    final now = DateTime.now();
    final deadlineDate = deadline.toDate();
    final difference = deadlineDate.difference(now);

    if (difference.inHours < 24) {
      return '${difference.inHours}h left';
    } else {
      return '${difference.inDays}d left';
    }
  }
}
