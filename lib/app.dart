import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/themes/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/profile/presentation/pages/detailed_profile_screen.dart';

class SenoritaApp extends StatelessWidget {
  const SenoritaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 13 Pro design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
            ),
          ],
          child: MaterialApp(
            title: 'Senorita - Premium Dating',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.glassmorphismTheme,
            darkTheme: AppTheme.glassmorphismTheme,
            themeMode: ThemeMode.dark,
            home: const DetailedProfileScreen(),
            routes: {
              '/detailed-profile': (context) => const DetailedProfileScreen(),
            },
          ),
        );
      },
    );
  }
}