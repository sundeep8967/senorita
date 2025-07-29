import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/firebase_auth_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource firebaseAuthDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.firebaseAuthDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> sendPhoneOtp(String phoneNumber) async {
    if (await networkInfo.isConnected) {
      try {
        await firebaseAuthDataSource.sendPhoneOtp(phoneNumber);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User>> verifyPhoneOtp(String phoneNumber, String otp) async {
    if (await networkInfo.isConnected) {
      try {
        // Note: For Firebase phone auth, we need verification ID, not phone number
        // This method signature might need to be updated to accept verificationId
        final userModel = await firebaseAuthDataSource.verifyPhoneOtp(phoneNumber, otp);
        await localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle() async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await firebaseAuthDataSource.signInWithGoogle();
        await localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      } catch (e) {
        return Left(AuthenticationFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithFacebook() async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await firebaseAuthDataSource.signInWithFacebook();
        await localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      } catch (e) {
        return Left(AuthenticationFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCachedUser();
      await localDataSource.clearAuthToken();
      await firebaseAuthDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // Try to get from Firebase first, then fallback to cache
      final userModel = await firebaseAuthDataSource.getCurrentUser();
      if (userModel != null) {
        await localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      }
      
      // Fallback to cached user
      final cachedUser = await localDataSource.getCachedUser();
      return Right(cachedUser?.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final user = await localDataSource.getCachedUser();
      final token = await localDataSource.getAuthToken();
      return Right(user != null && token != null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return firebaseAuthDataSource.authStateChanges.map((userModel) {
      if (userModel != null) {
        // Cache the user when auth state changes
        localDataSource.cacheUser(userModel);
        return userModel.toEntity();
      }
      return null;
    });
  }
}