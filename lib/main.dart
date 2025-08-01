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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a1a),
              Color(0xFF000000),
              Color(0xFF2d2d2d),
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
      left: (index * 60.0) % MediaQuery.of(context).size.width,
      top: (index * 80.0) % MediaQuery.of(context).size.height,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 2000 + (index * 500)),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.5 + (value * 0.5),
            child: Container(
              width: 100 + (index * 20.0),
              height: 100 + (index * 20.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.pinkAccent.withOpacity(0.1),
                    Colors.purpleAccent.withOpacity(0.1),
                  ],
                ),
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
          'RAYA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w300,
            letterSpacing: 8.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 60,
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.purpleAccent],
            ),
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
                ? Colors.white 
                : Colors.grey.withOpacity(0.4),
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
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w300,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 20),
        
        Text(
          slide.subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
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
              // Handle apply action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Apply to Join',
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
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.grey[600]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
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
            'Learn More About Raya',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCornerAccents() {
    return Stack(
      children: [
        // Top left
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.pinkAccent, width: 2),
                top: BorderSide(color: Colors.pinkAccent, width: 2),
              ),
            ),
          ),
        ),
        // Bottom right
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.purpleAccent, width: 2),
                bottom: BorderSide(color: Colors.purpleAccent, width: 2),
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

// Usage in main.dart:
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raya Welcome',
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