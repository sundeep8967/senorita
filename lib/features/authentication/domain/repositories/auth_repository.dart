import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> sendPhoneOtp(String phoneNumber);
  Future<Either<Failure, User>> verifyPhoneOtp(String phoneNumber, String otp);
  Future<Either<Failure, User>> loginWithGoogle();
  Future<Either<Failure, User>> loginWithFacebook();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, bool>> isLoggedIn();
  Stream<User?> get authStateChanges;
}