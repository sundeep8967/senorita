import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneOtp implements UseCase<User, VerifyPhoneOtpParams> {
  final AuthRepository repository;

  VerifyPhoneOtp(this.repository);

  @override
  Future<Either<Failure, User>> call(VerifyPhoneOtpParams params) async {
    return await repository.verifyPhoneOtp(params.phoneNumber, params.otp);
  }
}

class VerifyPhoneOtpParams extends Equatable {
  final String phoneNumber;
  final String otp;

  const VerifyPhoneOtpParams({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object> get props => [phoneNumber, otp];
}