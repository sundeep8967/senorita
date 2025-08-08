import 'package:flutter/material.dart';
import 'application_flow_screen.dart';
import 'home_screen.dart';

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
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;
  
  int _currentPage = 0;
  final List<SlideData> _slides = [
    SlideData(
      icon: "✨",
      title: "Discover\nConnections",
      subtitle: "Meet creative professionals and interesting people",
      color: const Color(0xFF6A5ACD),
    ),
    SlideData(
      icon: "🎭",
      title: "Curated\nCommunity", 
      subtitle: "Join an exclusive network of like-minded individuals",
      color: const Color(0xFF20B2AA),
    ),
    SlideData(
      icon: "💫",
      title: "Meaningful\nMatches",
      subtitle: "Quality over quantity in every connection",
      color: const Color(0xFFE63946),
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
    _slideController.forward();
    _shimmerController.repeat();
    
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
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        _startAutoSlide();
      }
    });
  }
  
  void _signInWithGoogle() async {
    // Show loading dialog with modern design
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF6A5ACD),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              const Text(
                'Signing in with Google...',
                style: TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    // Simulate Google sign-in process
    await Future.delayed(const Duration(seconds: 2));
    
    // Close loading dialog
    Navigator.pop(context);
    
    // Navigate directly to home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
  
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About Senorita',
                style: TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Senorita is an exclusive dating platform for creative professionals and interesting individuals. We focus on quality connections over quantity, bringing together like-minded people who value authenticity and meaningful relationships.',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  height: 1.5,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF6A5ACD),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
              Color(0xFFDEE2E6),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(8, (index) => _buildFloatingParticle(index)),
            
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Logo with shimmer effect
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildLogoWithShimmer(),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Modern progress indicator
                    _buildModernProgressIndicator(),
                    
                    const SizedBox(height: 30),
                    
                    // Slides with parallax effect
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
                          return _buildSlide(_slides[index], index);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Modern buttons
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildModernButtons(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Corner accents with glow effect
            _buildCornerAccents(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFloatingParticle(int index) {
    final size = 50.0 + (index * 15.0);
    final opacity = 0.1 + (index * 0.03);
    
    return Positioned(
      left: (index * 100.0) % MediaQuery.of(context).size.width,
      top: (index * 150.0) % MediaQuery.of(context).size.height,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 4000 + (index * 1000)),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(
              50 * (1 - value) * (index % 2 == 0 ? 1 : -1),
              30 * (1 - value) * (index % 3 == 0 ? 1 : -1),
            ),
            child: Transform.scale(
              scale: 0.5 + (value * 0.5),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      _slides[index % _slides.length].color.withOpacity(opacity),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _slides[index % _slides.length].color.withOpacity(opacity * 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildLogoWithShimmer() {
    return Column(
      children: [
        Stack(
          children: [
            const Text(
              'SENORITA',
              style: TextStyle(
                color: Color(0xFF1C1C1E),
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: 8.0,
              ),
            ),
            Positioned.fill(
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shimmerAnimation.value * 100, 0),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.5),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 4,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A5ACD), Color(0xFF20B2AA), Color(0xFFE63946)],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A5ACD).withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildModernProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (index) {
        final isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 30 : 10,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isActive 
                ? _slides[index].color 
                : const Color(0xFFC7C7CC),
            boxShadow: isActive ? [
              BoxShadow(
                color: _slides[index].color.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ] : [],
          ),
        );
      }),
    );
  }
  
  Widget _buildSlide(SlideData slide, int index) {
    final pageOffset = (_pageController.page ?? 0) - index;
    final scale = 1.0 - (pageOffset.abs() * 0.2);
    final opacity = 1.0 - (pageOffset.abs() * 0.5);
    
    return Transform.scale(
      scale: scale.clamp(0.8, 1.0),
      child: Opacity(
        opacity: opacity.clamp(0.5, 1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: slide.color.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        slide.icon,
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            Text(
              slide.title,
              style: TextStyle(
                color: slide.color,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            Text(
              slide.subtitle,
              style: const TextStyle(
                color: Color(0xFF6C757D),
                fontSize: 18,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModernButtons() {
    return Column(
      children: [
        // Apply to Join button with gradient
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A5ACD), Color(0xFF20B2AA)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A5ACD).withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
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
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Apply to Senorita',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // I Have a Code button with glassmorphism
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: OutlinedButton(
            onPressed: () {
              // Handle code action
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF495057),
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              side: const BorderSide(color: Colors.transparent),
            ),
            child: const Text(
              'I Have a Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Learn more link with modern styling
        GestureDetector(
          onTap: () {
            _showAboutDialog();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Learn More About Senorita',
              style: TextStyle(
                color: Color(0xFF495057),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Sign In section for existing members
        Column(
          children: [
            const Text(
              'Already a member?',
              style: TextStyle(
                color: Color(0xFF6C757D),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  _signInWithGoogle();
                },
                icon: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                label: const Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF495057),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1C1C1E),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildCornerAccents() {
    return Stack(
      children: [
        // Top left accent with glow
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.0,
                colors: [
                  const Color(0xFF6A5ACD).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom right accent with glow
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.0,
                colors: [
                  const Color(0xFF20B2AA).withOpacity(0.3),
                  Colors.transparent,
                ],
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
  final Color color;
  
  SlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}