import 'package:flutter/material.dart';
import '../models/date_selection.dart';
import '../services/date_selection_service.dart';
import '../services/firebase_service.dart';

class MatchedDatesCard extends StatefulWidget {
  final String chatRoomId;
  final String currentUserGender;

  const MatchedDatesCard({
    Key? key,
    required this.chatRoomId,
    required this.currentUserGender,
  }) : super(key: key);

  @override
  State<MatchedDatesCard> createState() => _MatchedDatesCardState();
}

class _MatchedDatesCardState extends State<MatchedDatesCard> {
  final DateSelectionService _dateSelectionService = DateSelectionService();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MeetupSchedule?>(
      stream: _dateSelectionService.streamMeetupSchedule(widget.chatRoomId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final schedule = snapshot.data!;
        final matchedDates = schedule.matchedDates;

        if (matchedDates.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withOpacity(0.3),
                Colors.pink.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.purple.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.celebration,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You both are available on ${matchedDates.length} date${matchedDates.length > 1 ? 's' : ''}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // List matched dates
              ...matchedDates.map((matchedDate) {
                return _buildMatchedDateItem(matchedDate);
              }).toList(),

              const SizedBox(height: 12),

              // Info text
              Text(
                _getInfoText(matchedDates),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchedDateItem(MatchedDate matchedDate) {
    final isGirl = widget.currentUserGender.toLowerCase() == 'female';
    final hasGirlTime = matchedDate.girlTime != null;
    final hasBoyTime = matchedDate.boyTime != null;
    final isConfirmed = matchedDate.isConfirmed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: isConfirmed
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConfirmed ? Icons.check_circle : Icons.calendar_today,
                color: isConfirmed ? Colors.green : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(matchedDate.date),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isConfirmed) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Confirmed',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Time selection
          Row(
            children: [
              // Girl's time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.female,
                          color: Colors.pink,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Her time:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (hasGirlTime)
                      Text(
                        _formatTime(matchedDate.girlTime!),
                        style: const TextStyle(
                          color: Colors.pink,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (isGirl)
                      TextButton(
                        onPressed: () => _selectTime(matchedDate.date, true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          backgroundColor: Colors.pink.withOpacity(0.2),
                        ),
                        child: const Text(
                          'Pick time',
                          style: TextStyle(color: Colors.pink, fontSize: 12),
                        ),
                      )
                    else
                      Text(
                        'Pending...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Boy's time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.male,
                          color: Colors.blue,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'His time:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (hasBoyTime)
                      Text(
                        _formatTime(matchedDate.boyTime!),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (!isGirl && hasGirlTime)
                      TextButton(
                        onPressed: () => _selectTime(matchedDate.date, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          backgroundColor: Colors.blue.withOpacity(0.2),
                        ),
                        child: const Text(
                          'Pick time',
                          style: TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      )
                    else
                      Text(
                        'Pending...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Final time display when confirmed
          if (isConfirmed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Meetup at ${_formatTime(matchedDate.girlTime!)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectTime(DateTime date, bool isGirl) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: isGirl ? Colors.pink : Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      await _dateSelectionService.saveTimeForMatchedDate(
        chatRoomId: widget.chatRoomId,
        date: date,
        time: time,
        isGirl: isGirl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isGirl
                ? '⏰ Time selected! Waiting for him to confirm.'
                : '✅ Time confirmed! Your meetup is set!',
          ),
          backgroundColor: isGirl ? Colors.pink : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getInfoText(List<MatchedDate> matchedDates) {
    final isGirl = widget.currentUserGender.toLowerCase() == 'female';
    
    // Check if there's any date where girl hasn't picked time yet
    final hasUnpickedGirlTime = matchedDates.any((md) => md.girlTime == null);
    final hasUnpickedBoyTime = matchedDates.any((md) => md.boyTime == null && md.girlTime != null);
    
    if (isGirl) {
      if (hasUnpickedGirlTime) {
        return '👑 As a lady, you get to pick the time first!';
      } else if (hasUnpickedBoyTime) {
        return '⏰ Waiting for him to pick his time...';
      } else {
        return '✅ All times confirmed! See you soon!';
      }
    } else {
      if (hasUnpickedGirlTime) {
        return '⏰ Waiting for her to pick the time first...';
      } else if (hasUnpickedBoyTime) {
        return '👍 Your turn! Pick your preferred time.';
      } else {
        return '✅ All times confirmed! See you soon!';
      }
    }
  }
}
