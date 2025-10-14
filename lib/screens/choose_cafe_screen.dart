import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senorita/features/meetup/data/repositories/meetup_repository_impl.dart';
import 'package:senorita/features/meetup/domain/models/meetup_model.dart';
import 'package:senorita/features/payment/app/payment_service.dart';
import 'package:senorita/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:senorita/features/payment/domain/repositories/payment_repository.dart';
import 'package:senorita/services/firebase_service.dart';
import 'package:senorita/screens/timer_screen.dart';
import 'package:senorita/models/user_profile.dart';

class ChooseCafeScreen extends StatefulWidget {
  final UserProfile? currentMatch;
  const ChooseCafeScreen({Key? key, this.currentMatch}) : super(key: key);

  @override
  State<ChooseCafeScreen> createState() => _ChooseCafeScreenState();
}

class _ChooseCafeScreenState extends State<ChooseCafeScreen> {
  String? _selectedCafe;

  void _selectCafe(String cafeName) {
    setState(() {
      _selectedCafe = cafeName;
    });
  }

  void _resetSelection() {
    setState(() {
      _selectedCafe = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: _selectedCafe == null
                  ? _buildCafeList()
                  : _buildConfirmationView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCafeList() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Choose a Cafe to Meet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              CafeTile(name: 'Sunny Cafe', onSelect: _selectCafe),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Invite Senorita to $_selectedCafe',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'First tea is on us',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'First maggie is on us',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _handleConfirmation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: const Text('Confirm', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _resetSelection,
          child: const Text(
            'Back to list',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _handleConfirmation() async {
    final firebaseService = FirebaseService();
    final meetupRepository = MeetupRepositoryImpl();
    
    final currentUserId = firebaseService.currentUserId;
    if (currentUserId == null || widget.currentMatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: User not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      },
    );

    try {
      // Create meetup request
      final meetup = Meetup(
        id: '', // Will be set by Firestore
        requestingUserId: currentUserId,
        invitedUserId: widget.currentMatch!.userId,
        hotelId: _selectedCafe ?? 'sunny_cafe',
        packageType: 'Coffee',
        packageCost: 299.0, // Default coffee price
        status: MeetupStatus.pending,
        createdAt: Timestamp.now(),
        paymentId: 'pending_payment', // Placeholder
      );

      final meetupId = await meetupRepository.createMeetup(meetup);
      
      // Hide loading indicator
      Navigator.pop(context);

      // Show success message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.9),
            title: const Text(
              'Request Sent!',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Your meetup request has been sent to ${widget.currentMatch!.fullName ?? 'Senorita'}. Check your timer for updates!',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: const Text('View Timer', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context); // Close alert
                  Navigator.pop(context); // Close cafe screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TimerScreen(),
                    ),
                  );
                },
              ),
              TextButton(
                child: const Text('OK', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.pop(context); // Close alert
                  Navigator.pop(context); // Close cafe screen
                },
              ),
            ],
          );
        },
      );

    } catch (e) {
      // Hide loading indicator
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending request: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class CafeTile extends StatelessWidget {
  final String name;
  final Function(String) onSelect;

  const CafeTile({Key? key, required this.name, required this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        name,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () => onSelect(name),
    );
  }
}
