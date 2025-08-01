import 'package:flutter/material.dart';

class LocationStepScreen extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onComplete;
  final VoidCallback onGetCurrentLocation;

  const LocationStepScreen({
    Key? key,
    required this.controller,
    required this.onComplete,
    required this.onGetCurrentLocation,
  }) : super(key: key);

  @override
  State<LocationStepScreen> createState() => _LocationStepScreenState();
}

class _LocationStepScreenState extends State<LocationStepScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Where are you located?',
            style: TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us connect you with people nearby',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 60),
          
          TextField(
            controller: widget.controller,
            style: const TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. New York, London, Tokyo',
              hintStyle: const TextStyle(
                color: Color(0xFFC7C7CC),
                fontSize: 18,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              setState(() {});
            },
          ),
          
          const SizedBox(height: 20),
          
          // Get Current Location Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: widget.onGetCurrentLocation,
              icon: const Icon(Icons.location_on, size: 20),
              label: const Text('Use Current Location'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF007AFF),
                side: const BorderSide(color: Color(0xFF007AFF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.controller.text.trim().isNotEmpty ? widget.onComplete : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
                disabledBackgroundColor: const Color(0xFFE5E5EA),
              ),
              child: const Text(
                'Complete Application',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}