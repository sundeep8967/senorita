import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_with_google.dart';
import '../../domain/usecases/send_phone_otp.dart';
import '../../domain/usecases/verify_phone_otp.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendPhoneOtp sendPhoneOtp;
  final VerifyPhoneOtp verifyPhoneOtp;
  final LoginWithGoogle loginWithGoogle;
  final GetCurrentUser getCurrentUser;

  AuthBloc({
    required this.sendPhoneOtp,
    required this.verifyPhoneOtp,
    required this.loginWithGoogle,
    required this.getCurrentUser,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SendPhoneOtpEvent>(_onSendPhoneOtp);
    on<VerifyPhoneOtpEvent>(_onVerifyPhoneOtp);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await getCurrentUser(NoParams());
    
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onSendPhoneOtp(
    SendPhoneOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await sendPhoneOtp(
      SendPhoneOtpParams(phoneNumber: event.phoneNumber),
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(OtpSent(phoneNumber: event.phoneNumber)),
    );
  }

  Future<void> _onVerifyPhoneOtp(
    VerifyPhoneOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await verifyPhoneOtp(
      VerifyPhoneOtpParams(
        phoneNumber: event.phoneNumber,
        otp: event.otp,
      ),
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('LoginWithGoogleEvent received in AuthBloc');
    emit(AuthLoading());
    
    final result = await loginWithGoogle(NoParams());
    
    result.fold(
      (failure) {
        print('Google login failed: ${failure.message}');
        emit(AuthError(message: failure.message));
      },
      (user) {
        print('Google login successful: ${user.email}');
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // Implement logout logic
    emit(AuthUnauthenticated());
  }
}