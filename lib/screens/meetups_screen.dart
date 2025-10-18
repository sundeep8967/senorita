import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/date_selection.dart';
import '../services/firebase_service.dart';
import '../services/date_selection_service.dart';

class MeetupsScreen extends StatelessWidget {
  const MeetupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseService().currentUserId;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.coffee, color: Colors.brown.shade300, size: 28),
            const SizedBox(width: 12),
            const Text(
              'My Meetups',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('meetup_schedules')
            .where('participantIds', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          // Convert to MeetupSchedule objects and filter confirmed meetups
          final meetups = snapshot.data!.docs
              .map((doc) => MeetupSchedule.fromFirestore(doc))
              .where((schedule) => schedule.matchedDates.any((md) => md.isConfirmed))
              .toList();

          if (meetups.isEmpty) {
            return _buildEmptyState();
          }

          // Sort by nearest date first
          final List<_MeetupItem> allMeetups = [];
          for (final schedule in meetups) {
            for (final matchedDate in schedule.matchedDates.where((md) => md.isConfirmed)) {
              allMeetups.add(_MeetupItem(
                schedule: schedule,
                matchedDate: matchedDate,
              ));
            }
          }

          allMeetups.sort((a, b) => a.matchedDate.date.compareTo(b.matchedDate.date));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allMeetups.length,
            itemBuilder: (context, index) {
              return _buildMeetupCard(context, allMeetups[index], currentUserId!);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.coffee_outlined,
            size: 100,
            color: Colors.brown.shade300.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Upcoming Meetups',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Plan dates to see your meetups here!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetupCard(BuildContext context, _MeetupItem item, String currentUserId) {
    final otherUserId = item.schedule.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    final isPast = item.matchedDate.date.isBefore(DateTime.now());
    final isToday = _isToday(item.matchedDate.date);
    final time = item.matchedDate.girlTime!;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, userSnapshot) {
        final otherUserName = userSnapshot.hasData
            ? ((userSnapshot.data!.data() as Map<String, dynamic>?)?['fullName'] ?? 'Someone')
            : 'Loading...';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPast
                  ? [Colors.grey.shade900, Colors.grey.shade800]
                  : isToday
                      ? [Colors.orange.shade900.withOpacity(0.4), Colors.orange.shade800.withOpacity(0.3)]
                      : [Colors.brown.shade900.withOpacity(0.4), Colors.brown.shade800.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isToday ? Colors.orange : Colors.brown.shade700.withOpacity(0.5),
              width: isToday ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isToday ? Colors.orange : Colors.brown.shade700).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isToday ? Icons.today : Icons.coffee,
                        color: isToday ? Colors.orange : Colors.brown.shade300,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            otherUserName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.white.withOpacity(0.7)),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(item.matchedDate.date),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'TODAY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.white.withOpacity(0.8), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _formatTime(time),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.qr_code_2, color: Colors.white.withOpacity(0.6), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Code Ready',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPast) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.history, size: 16, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(width: 8),
                      Text(
                        'Past Meetup',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dayOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
    return '$dayOfWeek, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class _MeetupItem {
  final MeetupSchedule schedule;
  final MatchedDate matchedDate;

  _MeetupItem({required this.schedule, required this.matchedDate});
}
