import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senorita/features/meetup/domain/models/meetup_model.dart';
import 'package:senorita/features/meetup/data/repositories/meetup_repository_impl.dart';
import 'package:senorita/services/firebase_service.dart';
import 'package:senorita/screens/chat_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  final MeetupRepositoryImpl _meetupRepository = MeetupRepositoryImpl();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Meetup Requests',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Accepted'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReceivedTab(),
          _buildAcceptedTab(),
          _buildSentTab(),
        ],
      ),
    );
  }
  
  Widget _buildReceivedTab() {
    return StreamBuilder<List<Meetup>>(
        stream: _meetupRepository.getMeetupsForUser(_firebaseService.currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading meetups: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          
          // Filter to show only received meetups that are pending
          final meetups = (snapshot.data ?? [])
              .where((m) => m.invitedUserId == _firebaseService.currentUserId && m.status == MeetupStatus.pending)
              .toList();
          
          if (meetups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 80,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No pending requests',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meetups.length,
            itemBuilder: (context, index) {
              final meetup = meetups[index];
              return _buildMeetupCard(meetup);
            },
          );
        },
      );
  }
  
  Widget _buildAcceptedTab() {
    return StreamBuilder<List<Meetup>>(
        stream: _meetupRepository.getMeetupsForUser(_firebaseService.currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading meetups: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          
          // Filter to show only accepted meetups
          final meetups = (snapshot.data ?? [])
              .where((m) => m.status == MeetupStatus.accepted)
              .toList();
          
          if (meetups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No accepted meetups',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meetups.length,
            itemBuilder: (context, index) {
              final meetup = meetups[index];
              return _buildMeetupCard(meetup);
            },
          );
        },
      );
  }
  
  Widget _buildSentTab() {
    return StreamBuilder<List<Meetup>>(
        stream: _meetupRepository.getMeetupsForUser(_firebaseService.currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading meetups: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          
          // Filter to show only sent meetups
          final meetups = (snapshot.data ?? [])
              .where((m) => m.requestingUserId == _firebaseService.currentUserId)
              .toList();
          
          if (meetups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_outlined,
                    size: 80,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No sent requests',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meetups.length,
            itemBuilder: (context, index) {
              final meetup = meetups[index];
              return _buildMeetupCard(meetup);
            },
          );
        },
      );
  }
  
  Widget _buildMeetupCard(Meetup meetup) {
    final isRequestSent = meetup.requestingUserId == _firebaseService.currentUserId;
    final isRequestReceived = meetup.invitedUserId == _firebaseService.currentUserId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(meetup.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(meetup.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(meetup.createdAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (isRequestSent) ...[
                  const Row(
                    children: [
                      Icon(Icons.send, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Request Sent',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You invited someone for ${meetup.packageType} at Sunny Cafe',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
                
                if (isRequestReceived) ...[
                  const Row(
                    children: [
                      Icon(Icons.inbox, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Request Received',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Someone invited you for ${meetup.packageType} at Sunny Cafe',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    const Icon(Icons.local_cafe, color: Colors.brown, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      meetup.packageType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₹${meetup.packageCost.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                if (isRequestReceived) ...[
                  if (meetup.status == MeetupStatus.pending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleMeetupResponse(meetup.id, MeetupStatus.accepted),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Accept', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleMeetupResponse(meetup.id, MeetupStatus.declined),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Decline', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  ] else if (meetup.status == MeetupStatus.accepted) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _navigateToChat(meetup),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Open Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getStatusColor(MeetupStatus status) {
    switch (status) {
      case MeetupStatus.pending:
        return Colors.orange;
      case MeetupStatus.accepted:
        return Colors.green;
      case MeetupStatus.declined:
        return Colors.red;
      case MeetupStatus.completed:
        return Colors.blue;
      case MeetupStatus.cancelled:
        return Colors.grey;
    }
  }
  
  String _getStatusText(MeetupStatus status) {
    switch (status) {
      case MeetupStatus.pending:
        return 'Pending';
      case MeetupStatus.accepted:
        return 'Accepted';
      case MeetupStatus.declined:
        return 'Declined';
      case MeetupStatus.completed:
        return 'Completed';
      case MeetupStatus.cancelled:
        return 'Cancelled';
    }
  }
  
  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
  
  Future<void> _handleMeetupResponse(String meetupId, MeetupStatus status) async {
    try {
      HapticFeedback.lightImpact();
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      status == MeetupStatus.accepted ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    status == MeetupStatus.accepted 
                        ? 'Accepting meetup...' 
                        : 'Declining meetup...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      
      // Get meetup details first to know who to create chat with
      final meetup = await _meetupRepository.getMeetupDetails(meetupId);
      if (meetup == null) {
        Navigator.of(context).pop(); // Close loading dialog
        throw Exception('Meetup not found');
      }
      
      // Update meetup status
      await _meetupRepository.updateMeetupStatus(meetupId, status);
      
      // Small delay to show the loading indicator
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Force UI refresh by rebuilding
      if (mounted) {
        setState(() {});
      }
      
      if (status == MeetupStatus.accepted) {
        // Navigate to chat after accepting
        await Future.delayed(const Duration(milliseconds: 300));
        _navigateToChat(meetup);
      } else {
        // Show declined message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meetup declined'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      Navigator.of(context).pop();
      
      print('❌ Error handling meetup response: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToChat(Meetup meetup) async {
    try {
      // Determine the other user
      final currentUserId = _firebaseService.currentUserId;
      if (currentUserId == null) return;
      
      final otherUserId = currentUserId == meetup.requestingUserId
          ? meetup.invitedUserId
          : meetup.requestingUserId;
      
      // Get other user's profile
      final otherUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get();
      
      if (!otherUserDoc.exists) {
        print('❌ Other user not found');
        return;
      }
      
      final otherUserData = otherUserDoc.data()!;
      final otherUserName = otherUserData['fullName'] ?? 'User';
      final otherUserAvatar = (otherUserData['photos'] as List<dynamic>?)?.isNotEmpty == true
          ? otherUserData['photos'][0]
          : '';
      
      // Navigate to chat screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            otherUserId: otherUserId,
            otherUserName: otherUserName,
            otherUserAvatar: otherUserAvatar,
          ),
        ),
      );
    } catch (e) {
      print('❌ Error navigating to chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error opening chat'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}