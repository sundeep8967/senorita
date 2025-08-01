import 'package:flutter/material.dart';

class AgeStepScreen extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onNext;

  const AgeStepScreen({
    Key? key,
    required this.controller,
    required this.onNext,
  }) : super(key: key);

  @override
  State<AgeStepScreen> createState() => _AgeStepScreenState();
}

class _AgeStepScreenState extends State<AgeStepScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'How old are you?',
            style: TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You must be 18 or older to join Senorita',
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
              hintText: 'Enter your age',
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
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {});
            },
          ),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.controller.text.trim().isNotEmpty && 
                         int.tryParse(widget.controller.text) != null &&
                         int.parse(widget.controller.text) >= 18 ? widget.onNext : null,
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