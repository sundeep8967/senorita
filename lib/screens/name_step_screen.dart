import 'package:flutter/material.dart';

class NameStepScreen extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onNext;

  const NameStepScreen({
    Key? key,
    required this.controller,
    required this.onNext,
  }) : super(key: key);

  @override
  State<NameStepScreen> createState() => _NameStepScreenState();
}

class _NameStepScreenState extends State<NameStepScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'What\'s your name?',
            style: TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This is how you\'ll appear to other members',
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
              hintText: 'Enter your full name',
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
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.controller.text.trim().isNotEmpty ? widget.onNext : null,
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
                'Continue',
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