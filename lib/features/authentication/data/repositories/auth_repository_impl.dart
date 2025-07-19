import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final GoogleSignIn googleSignIn;
  final FacebookAuth facebookAuth;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.googleSignIn,
    required this.facebookAuth,
  });

  @override
  Future<Either<Failure, void>> sendPhoneOtp(String phoneNumber) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendPhoneOtp(phoneNumber);
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
        final userModel = await remoteDataSource.verifyPhoneOtp(phoneNumber, otp);
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
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          return const Left(AuthenticationFailure('Google sign in was cancelled'));
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final String? idToken = googleAuth.idToken;

        if (idToken == null) {
          return const Left(AuthenticationFailure('Failed to get Google ID token'));
        }

        final userModel = await remoteDataSource.loginWithGoogle(idToken);
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
        final LoginResult result = await facebookAuth.login();
        
        if (result.status == LoginStatus.success) {
          final AccessToken? accessToken = result.accessToken;
          if (accessToken == null) {
            return const Left(AuthenticationFailure('Failed to get Facebook access token'));
          }

          final userModel = await remoteDataSource.loginWithFacebook(accessToken.token);
          await localDataSource.cacheUser(userModel);
          return Right(userModel.toEntity());
        } else {
          return Left(AuthenticationFailure('Facebook login failed: ${result.message}'));
        }
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
      await googleSignIn.signOut();
      await facebookAuth.logOut();
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCachedUser();
      return Right(userModel?.toEntity());
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
    // This would typically be implemented with Firebase Auth or similar
    // For now, return an empty stream
    return Stream.empty();
  }
}