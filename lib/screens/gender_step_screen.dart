import 'package:flutter/material.dart';

class GenderStepScreen extends StatefulWidget {
  final VoidCallback onNext;
  final Function(String) onGenderSelected;
  final String? selectedGender;

  const GenderStepScreen({
    Key? key,
    required this.onNext,
    required this.onGenderSelected,
    this.selectedGender,
  }) : super(key: key);

  @override
  State<GenderStepScreen> createState() => _GenderStepScreenState();
}

class _GenderStepScreenState extends State<GenderStepScreen> {
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.selectedGender;
  }

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
    widget.onGenderSelected(gender);
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
            'What\'s your gender?',
            style: TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us create better matches for you',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 60),
          
          // Male Button
          _buildGenderButton(
            gender: 'Male',
            icon: Icons.male,
            isSelected: _selectedGender == 'Male',
            onTap: () => _selectGender('Male'),
          ),
          
          const SizedBox(height: 16),
          
          // Female Button
          _buildGenderButton(
            gender: 'Female',
            icon: Icons.female,
            isSelected: _selectedGender == 'Female',
            onTap: () => _selectGender('Female'),
          ),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedGender != null ? widget.onNext : null,
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

  Widget _buildGenderButton({
    required String gender,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA),
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF007AFF).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF007AFF),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1C1C1E),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}