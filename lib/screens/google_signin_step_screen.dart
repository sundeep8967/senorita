import 'package:flutter/material.dart';

class GoogleSignInStepScreen extends StatefulWidget {
  final VoidCallback onNext;

  const GoogleSignInStepScreen({
    Key? key,
    required this.onNext,
  }) : super(key: key);

  @override
  State<GoogleSignInStepScreen> createState() => _GoogleSignInStepScreenState();
}

class _GoogleSignInStepScreenState extends State<GoogleSignInStepScreen> {
  bool _isSigningIn = false;

  void _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
    });

    // Simulate Google Sign-In process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSigningIn = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Successfully signed in with Google!'),
        backgroundColor: const Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // Proceed to next step
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.security,
              size: 40,
              color: Color(0xFF007AFF),
            ),
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Secure Sign-In Required',
            style: TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'To ensure the security and authenticity of our community, we require Google Sign-In for all new members.',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Benefits list
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildBenefitItem(
                  icon: Icons.verified_user,
                  title: 'Verified Identity',
                  subtitle: 'Ensures authentic community members',
                ),
                const SizedBox(height: 16),
                _buildBenefitItem(
                  icon: Icons.security,
                  title: 'Secure Account',
                  subtitle: 'Protected by Google\'s security',
                ),
                const SizedBox(height: 16),
                _buildBenefitItem(
                  icon: Icons.speed,
                  title: 'Quick Setup',
                  subtitle: 'Fast and easy registration process',
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Google Sign-In Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isSigningIn ? null : _signInWithGoogle,
              icon: _isSigningIn 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
              label: Text(
                _isSigningIn ? 'Signing in...' : 'Continue with Google',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1C1C1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                side: const BorderSide(
                  color: Color(0xFFE5E5EA),
                  width: 1,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Privacy note
          const Text(
            'We only access your basic profile information\nand will never post without your permission.',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF007AFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF007AFF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}