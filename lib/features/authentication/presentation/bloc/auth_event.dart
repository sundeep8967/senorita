part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SendPhoneOtpEvent extends AuthEvent {
  final String phoneNumber;

  const SendPhoneOtpEvent({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyPhoneOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const VerifyPhoneOtpEvent({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object> get props => [phoneNumber, otp];
}

class LoginWithGoogleEvent extends AuthEvent {}

class LoginWithFacebookEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}