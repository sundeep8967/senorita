import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/themes/premium_theme.dart';
import 'core/navigation/app_router.dart';
import 'features/onboarding/presentation/pages/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const SenoritaApp());
}

class SenoritaApp extends StatelessWidget {
  const SenoritaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set iOS-style status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 13 Pro design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Senorita - Premium Dating',
          debugShowCheckedModeBanner: false,
          theme: PremiumTheme.lightTheme,
          darkTheme: PremiumTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const SplashScreen(),
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}