import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:senorita/features/meetup/data/repositories/meetup_repository_impl.dart';
import 'package:senorita/features/payment/app/payment_service.dart';
import 'package:senorita/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:senorita/features/payment/domain/repositories/payment_repository.dart';

class ChooseCafeScreen extends StatefulWidget {
  const ChooseCafeScreen({Key? key}) : super(key: key);

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
              CafeTile(name: 'Starbucks', onSelect: _selectCafe),
              CafeTile(name: 'Cafe Coffee Day', onSelect: _selectCafe),
              CafeTile(name: 'The Coffee Bean & Tea Leaf', onSelect: _selectCafe),
              CafeTile(name: 'Costa Coffee', onSelect: _selectCafe),
              CafeTile(name: 'Barista', onSelect: _selectCafe),
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
    // This is where the end-to-end flow is kicked off.
    // In a real app, these would be provided by a dependency injection solution.
    final paymentRepository = PaymentRepositoryImpl();
    final meetupRepository = MeetupRepositoryImpl();
    final paymentService = PaymentService(
      paymentRepository: paymentRepository,
      meetupRepository: meetupRepository,
    );

    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Hardcoded data for verification purposes
    final success = await paymentService.initiatePaidMeetup(
      requestingUserId: 'user_boy_123', // Dummy ID for the user paying
      invitedUserId: 'user_girl_456', // Dummy ID for the user being invited
      hotelId: _selectedCafe ?? 'default_cafe',
      packageType: 'Coffee',
      packageCost: 500.0,
      paymentRequest: PaymentRequest(
        amount: 500.0,
        currency: 'INR',
        userName: 'Test User',
        userEmail: 'test@example.com',
        userPhone: '9876543210',
      ),
    );

    // Hide loading indicator
    Navigator.pop(context);

    // Show result to the user
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(success ? 'Request Sent!' : 'Request Failed'),
          content: Text(success
              ? 'Your meetup request has been sent successfully.'
              : 'There was an error processing your request. Please try again.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context); // Close the alert
                if (success) {
                  Navigator.pop(context); // Close the cafe screen
                }
              },
            ),
          ],
        );
      },
    );
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
