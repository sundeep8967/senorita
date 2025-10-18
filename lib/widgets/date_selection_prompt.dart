import 'package:flutter/material.dart';
import '../models/date_selection.dart';
import '../services/date_selection_service.dart';
import '../services/firebase_service.dart';
import 'meetup_calendar_widget.dart';

class DateSelectionPrompt extends StatelessWidget {
  final String chatRoomId;
  final String otherUserId;
  final String currentUserGender;

  const DateSelectionPrompt({
    Key? key,
    required this.chatRoomId,
    required this.otherUserId,
    required this.currentUserGender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DateSelection>>(
      stream: DateSelectionService().streamDateSelections(chatRoomId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final dateSelections = snapshot.data!;
        final currentUserId = FirebaseService().currentUserId;
        
        // Find current user's selection
        final mySelections = dateSelections.where((s) => s.userId == currentUserId).toList();
        final theirSelections = dateSelections.where((s) => s.userId != currentUserId).toList();
        
        final mySelection = mySelections.isNotEmpty ? mySelections.first : null;
        final theirSelection = theirSelections.isNotEmpty ? theirSelections.first : null;

        final hasMySelection = mySelection != null && mySelection.selectedDates.isNotEmpty;
        final hasTheirSelection = theirSelection != null && theirSelection.selectedDates.isNotEmpty;

        // Don't show prompt if both have selected dates (will show matched dates card instead)
        if (hasMySelection && hasTheirSelection) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withOpacity(0.2),
                Colors.blue.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.purple.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: Colors.purple.shade300,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getHeaderText(hasMySelection, hasTheirSelection),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Text(
                _getDescriptionText(hasMySelection, hasTheirSelection),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Selection status
              _buildSelectionStatus(hasMySelection, hasTheirSelection),
              
              const SizedBox(height: 16),
              
              // Action button
              if (!hasMySelection)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openCalendar(context),
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text(
                      'Select Your Available Dates',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openCalendar(context),
                        icon: const Icon(Icons.edit_calendar, size: 16),
                        label: const Text('Edit Dates'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${mySelection!.selectedDates.length} dates',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectionStatus(bool hasMySelection, bool hasTheirSelection) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: hasMySelection
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasMySelection ? Colors.green : Colors.grey.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasMySelection ? Icons.check_circle : Icons.circle_outlined,
                  color: hasMySelection ? Colors.green : Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'You',
                  style: TextStyle(
                    color: hasMySelection ? Colors.green : Colors.white54,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: hasTheirSelection
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasTheirSelection ? Colors.green : Colors.grey.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasTheirSelection ? Icons.check_circle : Icons.circle_outlined,
                  color: hasTheirSelection ? Colors.green : Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Them',
                  style: TextStyle(
                    color: hasTheirSelection ? Colors.green : Colors.white54,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getHeaderText(bool hasMySelection, bool hasTheirSelection) {
    if (!hasMySelection && !hasTheirSelection) {
      return '📅 Plan Your First Meetup';
    } else if (hasMySelection && !hasTheirSelection) {
      return '⏳ Waiting for Their Response';
    } else if (!hasMySelection && hasTheirSelection) {
      return '💡 Your Turn to Select Dates';
    }
    return 'Date Selection';
  }

  String _getDescriptionText(bool hasMySelection, bool hasTheirSelection) {
    if (!hasMySelection && !hasTheirSelection) {
      return 'Both of you need to select your available dates. Once you both choose, we\'ll find dates that work for both of you!';
    } else if (hasMySelection && !hasTheirSelection) {
      return 'Great! You\'ve selected your dates. Now waiting for them to select their available dates.';
    } else if (!hasMySelection && hasTheirSelection) {
      return 'They\'ve already selected their dates. Select yours now to find matching dates!';
    }
    return '';
  }

  void _openCalendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MeetupCalendarWidget(
        chatRoomId: chatRoomId,
        otherUserId: otherUserId,
        currentUserGender: currentUserGender,
      ),
    );
  }
}
