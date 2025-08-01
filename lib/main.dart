import 'package:flutter/material.dart';

class RayaWelcomeScreen extends StatefulWidget {
  const RayaWelcomeScreen({Key? key}) : super(key: key);

  @override
  State<RayaWelcomeScreen> createState() => _RayaWelcomeScreenState();
}

class _RayaWelcomeScreenState extends State<RayaWelcomeScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentPage = 0;

  final List<SlideData> _slides = [
    SlideData(
      icon: "✨",
      title: "Discover\nConnections",
      subtitle: "Meet creative professionals and interesting people",
    ),
    SlideData(
      icon: "🎭",
      title: "Curated\nCommunity", 
      subtitle: "Join an exclusive network of like-minded individuals",
    ),
    SlideData(
      icon: "💫",
      title: "Meaningful\nMatches",
      subtitle: "Quality over quantity in every connection",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
    
    // Auto-advance slides
    Future.delayed(const Duration(seconds: 1), () {
      _startAutoSlide();
    });
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        final nextPage = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoSlide();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4, 0.8, 1.0],
            colors: [
              Color(0xFFF2F2F7), // iOS light background
              Color(0xFFE5E5EA), // iOS secondary background
              Color(0xFFD1D1D6), // iOS tertiary background
              Color(0xFFC7C7CC), // iOS quaternary background
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background animated elements
            ...List.generate(6, (index) => _buildFloatingElement(index)),
            
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    // Logo
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildLogo(),
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Page indicators
                    _buildPageIndicators(),
                    
                    const SizedBox(height: 40),
                    
                    // Slides
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: _slides.length,
                        itemBuilder: (context, index) {
                          return _buildSlide(_slides[index]);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Buttons
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildBottomButtons(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Corner accents
            _buildCornerAccents(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElement(int index) {
    return Positioned(
      left: (index * 80.0) % MediaQuery.of(context).size.width,
      top: (index * 120.0) % MediaQuery.of(context).size.height,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 3000 + (index * 800)),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.3 + (value * 0.4),
            child: Container(
              width: 120 + (index * 15.0),
              height: 120 + (index * 15.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.5,
                  colors: [
                    Color(0xFF007AFF).withOpacity(0.15), // More visible on light bg
                    Color(0xFF5856D6).withOpacity(0.12), // More visible on light bg
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF007AFF).withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        const Text(
          'SENORITA',
          style: TextStyle(
            color: Color(0xFF1C1C1E), // iOS label color
            fontSize: 32,
            fontWeight: FontWeight.w600, // More iOS-like weight
            letterSpacing: 8.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 60,
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF5856D6)], // iOS blue to purple
            ),
            borderRadius: BorderRadius.all(Radius.circular(1)),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF007AFF),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 12 : 8,
          height: _currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index 
                ? const Color(0xFF007AFF) // iOS blue for active
                : const Color(0xFFC7C7CC), // iOS quaternary label
          ),
        );
      }),
    );
  }

  Widget _buildSlide(SlideData slide) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Text(
                  slide.icon,
                  style: const TextStyle(fontSize: 80),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 40),
        
        Text(
          slide.title,
          style: const TextStyle(
            color: Color(0xFF1C1C1E), // iOS label color
            fontSize: 28,
            fontWeight: FontWeight.w600, // iOS-style semibold
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 20),
        
        Text(
          slide.subtitle,
          style: const TextStyle(
            color: Color(0xFF8E8E93), // iOS secondary label
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Column(
      children: [
        // Apply to Join button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SenoritaApplicationScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF), // iOS blue
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 2,
              shadowColor: const Color(0xFF007AFF).withOpacity(0.3),
            ),
            child: const Text(
              'Apply to Senorita',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // I Have a Code button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              // Handle code action
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1C1C1E), // Dark text on light bg
              side: const BorderSide(color: Color(0xFFC7C7CC), width: 1), // iOS separator
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              backgroundColor: Colors.white.withOpacity(0.8), // Light background
            ),
            child: const Text(
              'I Have a Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Learn more link
        TextButton(
          onPressed: () {
            // Handle learn more
          },
          child: Text(
            'Learn More About Senorita',
            style: const TextStyle(
              color: Color(0xFF8E8E93), // iOS secondary label color
              fontSize: 14,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF8E8E93),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCornerAccents() {
    return Stack(
      children: [
        // Top left subtle glow
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.0,
                colors: [
                  const Color(0xFF007AFF).withOpacity(0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        // Bottom right subtle glow
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.0,
                colors: [
                  const Color(0xFF5856D6).withOpacity(0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SlideData {
  final String icon;
  final String title;
  final String subtitle;

  SlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class SenoritaApplicationScreen extends StatefulWidget {
  const SenoritaApplicationScreen({Key? key}) : super(key: key);

  @override
  State<SenoritaApplicationScreen> createState() => _SenoritaApplicationScreenState();
}

class _SenoritaApplicationScreenState extends State<SenoritaApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Music',
    'Art',
    'Film',
    'Tech',
    'Fashion',
    'Business',
    'Sports',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apply to Senorita',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pinkAccent, Colors.purpleAccent],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Email Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Primary Category'),
                value: _selectedCategory,
                items: _categories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Bio Field
              TextFormField(
                controller: _bioController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: _buildInputDecoration('Tell us about yourself'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please tell us about yourself';
                  }
                  if (value.length < 50) {
                    return 'Please write at least 50 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              
              // Continue with Google Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _continueWithGoogle();
                  },
                  icon: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Submit Application',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Note
              Text(
                'We review each application carefully. You\'ll hear back from us within 2-3 weeks.',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[500]),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.purpleAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));
      
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Application Submitted',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Thank you for applying to Senorita. We\'ll review your application and notify you soon.',
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to welcome screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      
      setState(() => _isSubmitting = false);
    }
  }

  void _continueWithGoogle() async {
    // Show loading state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF007AFF)),
            const SizedBox(height: 16),
            Text(
              'Connecting with Google...',
              style: TextStyle(color: Colors.grey[300]),
            ),
          ],
        ),
      ),
    );

    // Simulate Google sign-in process
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog
    Navigator.pop(context);

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Welcome to Senorita!',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'You have successfully signed in with Google. Welcome to the Senorita community!',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to welcome screen
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

// Usage in main.dart:
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Senorita Welcome',
      theme: ThemeData.dark(),
      home: const RayaWelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Add this right after the MyApp class (at the very end of the file):

void main() {
  runApp( MyApp());
}