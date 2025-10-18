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
        final userCode = currentUserGender == 'female'
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                currentUserGender == 'female'
                    ? Colors.pink.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
                currentUserGender == 'female'
                    ? Colors.pink.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: currentUserGender == 'female'
                  ? Colors.pink.withOpacity(0.5)
                  : Colors.blue.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.qr_code_2,
                    color: currentUserGender == 'female' ? Colors.pink : Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Your Cafe Verification Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Code display
              Center(
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: userCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copied to clipboard!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userCode,
                          style: TextStyle(
                            color: currentUserGender == 'female'
                                ? Colors.pink
                                : Colors.blue,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.copy,
                          color: Colors.white.withOpacity(0.7),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Instructions
              Text(
                '📱 Show this code at the cafe to confirm your arrival',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              // Deadline warning
              if (showDeadlineWarning) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getDeadlineWarningText(schedule.selectionDeadline!),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
      return '⏰ ${difference.inHours}h left to select dates or meetup will be cancelled!';
    } else {
      return '⏰ ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} left to select dates';
    }
  }
}
