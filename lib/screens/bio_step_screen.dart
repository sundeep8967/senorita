import 'package:flutter/material.dart';

class BioStepScreen extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onComplete;

  const BioStepScreen({
    Key? key,
    required this.controller,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<BioStepScreen> createState() => _BioStepScreenState();
}

class _BioStepScreenState extends State<BioStepScreen> {
  String _bioText = '';
  final int _maxBioLength = 500;
  final int _minBioLength = 50;

  @override
  void initState() {
    super.initState();
    _bioText = widget.controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Tell us about yourself',
            style: TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Write a brief bio to help others get to know you better',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          
          // Bio input area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _bioText.length >= _minBioLength 
                      ? const Color(0xFF007AFF) 
                      : const Color(0xFFE5E5EA),
                  width: 2,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                maxLines: null,
                maxLength: _maxBioLength,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontSize: 16,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'Share your interests, hobbies, what you\'re looking for...\n\nFor example:\n• I love hiking and photography\n• Coffee enthusiast and book lover\n• Looking for meaningful connections\n• Passionate about travel and new experiences',
                  hintStyle: const TextStyle(
                    color: Color(0xFFC7C7CC),
                    fontSize: 15,
                    height: 1.4,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  counterStyle: TextStyle(
                    color: _bioText.length >= _minBioLength 
                        ? const Color(0xFF007AFF) 
                        : const Color(0xFF8E8E93),
                    fontSize: 14,
                  ),
                  alignLabelWithHint: true,
                  isCollapsed: false,
                ),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  setState(() {
                    _bioText = text;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Progress indicator and tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bioText.length >= _minBioLength 
                  ? const Color(0xFF007AFF).withOpacity(0.1)
                  : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_bioText.length}/$_maxBioLength characters',
                      style: TextStyle(
                        color: _bioText.length >= _minBioLength 
                            ? const Color(0xFF007AFF) 
                            : const Color(0xFF8E8E93),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_bioText.length >= _minBioLength)
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF34C759), size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Looking good!',
                            style: TextStyle(
                              color: Color(0xFF34C759),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                
                if (_bioText.length < _minBioLength) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _bioText.length / _minBioLength,
                    backgroundColor: const Color(0xFFE5E5EA),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                    minHeight: 4,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Minimum ${_minBioLength - _bioText.length} more characters needed',
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Tips section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Color(0xFF007AFF), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tips for a great bio:',
                      style: TextStyle(
                        color: Color(0xFF1C1C1E),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTip('Be authentic and genuine'),
                _buildTip('Share your passions and interests'),
                _buildTip('Mention what you\'re looking for'),
                _buildTip('Keep it positive and engaging'),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Continue button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _bioText.trim().length >= _minBioLength ? widget.onComplete : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
                disabledBackgroundColor: const Color(0xFFE5E5EA),
              ),
              child: Text(
                _bioText.trim().length >= _minBioLength 
                    ? 'Continue' 
                    : 'Write a bit more...',
                style: const TextStyle(
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

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Text(
            '•',
            style: TextStyle(
              color: Color(0xFF007AFF),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}