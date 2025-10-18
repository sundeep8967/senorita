import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/date_selection.dart';
import '../services/date_selection_service.dart';
import '../services/firebase_service.dart';

class MeetupCalendarWidget extends StatefulWidget {
  final String chatRoomId;
  final String otherUserId;
  final String currentUserGender;

  const MeetupCalendarWidget({
    Key? key,
    required this.chatRoomId,
    required this.otherUserId,
    required this.currentUserGender,
  }) : super(key: key);

  @override
  State<MeetupCalendarWidget> createState() => _MeetupCalendarWidgetState();
}

class _MeetupCalendarWidgetState extends State<MeetupCalendarWidget> {
  final DateSelectionService _dateSelectionService = DateSelectionService();
  final FirebaseService _firebaseService = FirebaseService();

  DateTime _focusedMonth = DateTime.now();
  List<DateTime> _selectedDates = [];
  List<DateTime> _otherUserDates = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDateSelections();
  }

  Future<void> _loadDateSelections() async {
    try {
      final currentUserId = _firebaseService.currentUserId!;

      // Load current user's selections
      final mySelection = await _dateSelectionService.getDateSelection(
        widget.chatRoomId,
        currentUserId,
      );

      // Load other user's selections
      final otherSelection = await _dateSelectionService.getDateSelection(
        widget.chatRoomId,
        widget.otherUserId,
      );

      setState(() {
        _selectedDates = mySelection?.selectedDates ?? [];
        _otherUserDates = otherSelection?.selectedDates ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading date selections: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleDate(DateTime date) {
    setState(() {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final index = _selectedDates.indexWhere((d) =>
          d.year == normalizedDate.year &&
          d.month == normalizedDate.month &&
          d.day == normalizedDate.day);

      if (index >= 0) {
        _selectedDates.removeAt(index);
      } else {
        _selectedDates.add(normalizedDate);
      }
    });
  }

  Future<void> _saveDateSelection() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final currentUserId = _firebaseService.currentUserId!;

      await _dateSelectionService.saveDateSelection(
        chatRoomId: widget.chatRoomId,
        userId: currentUserId,
        selectedDates: _selectedDates,
        gender: widget.currentUserGender,
      );

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dates saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving dates: $e');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving dates'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getDateColor(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    final isMyDate = _selectedDates.any((d) =>
        d.year == normalizedDate.year &&
        d.month == normalizedDate.month &&
        d.day == normalizedDate.day);
    
    final isOtherDate = _otherUserDates.any((d) =>
        d.year == normalizedDate.year &&
        d.month == normalizedDate.month &&
        d.day == normalizedDate.day);

    if (isMyDate && isOtherDate) {
      // Both selected - purple (mix of blue and pink)
      return Colors.purple;
    } else if (isMyDate) {
      // Current user selected
      return widget.currentUserGender.toLowerCase() == 'female' ? Colors.pink : Colors.blue;
    } else if (isOtherDate) {
      // Other user selected - show with transparency
      final otherGender = widget.currentUserGender.toLowerCase() == 'female' ? 'male' : 'female';
      return (otherGender == 'female' ? Colors.pink : Colors.blue).withOpacity(0.3);
    }

    return Colors.transparent;
  }

  bool _isDateSelected(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _selectedDates.any((d) =>
        d.year == normalizedDate.year &&
        d.month == normalizedDate.month &&
        d.day == normalizedDate.day);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select Available Dates',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildLegendItem(
                  widget.currentUserGender.toLowerCase() == 'female' ? Colors.pink : Colors.blue,
                  'Your dates',
                ),
                const SizedBox(width: 16),
                _buildLegendItem(
                  (widget.currentUserGender.toLowerCase() == 'female' ? Colors.blue : Colors.pink)
                      .withOpacity(0.3),
                  'Their dates',
                ),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.purple, 'Match!'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  _getMonthYearString(_focusedMonth),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Calendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildCalendarGrid(),
          ),

          const SizedBox(height: 20),

          // Save button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedDates.isEmpty || _isSaving ? null : _saveDateSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[700],
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _selectedDates.isEmpty
                            ? 'Select dates to continue'
                            : 'Save ${_selectedDates.length} date${_selectedDates.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 10),

        // Calendar days
        ...List.generate((daysInMonth + startingWeekday) ~/ 7 + 1, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - startingWeekday + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox(width: 40, height: 40);
                }

                final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
                final isToday = _isToday(date);
                final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                final color = _getDateColor(date);
                final isSelected = _isDateSelected(date);

                return GestureDetector(
                  onTap: isPast ? null : () => _toggleDate(date),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: Colors.white, width: 2)
                          : isSelected
                              ? Border.all(color: Colors.white, width: 1)
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          color: isPast
                              ? Colors.white.withOpacity(0.3)
                              : isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
