import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/themes/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/pages/login/login_page.dart';
import 'features/profile/presentation/pages/profile_setup/profile_setup_page.dart';

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
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is AuthAuthenticated) {
                  if (!state.user.isProfileComplete) {
                    return ProfileSetupPage(
                      phoneNumber: state.user.phoneNumber,
                      userName: state.user.name,
                      email: state.user.email,
                    );
                  }
                  // Navigate to home screen
                  return const Scaffold(
                    body: Center(
                      child: Text('Welcome to Senorita!'),
                    ),
                  );
                } else {
                  return const LoginPage();
                }
              },
            ),
            routes: {
              '/login': (context) => const LoginPage(),
              '/profile-setup': (context) => const ProfileSetupPage(
                phoneNumber: '',
              ),
            },
          ),
        );
      },
    );
  }
}