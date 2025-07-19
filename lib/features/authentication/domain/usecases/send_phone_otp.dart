import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendPhoneOtp implements UseCase<void, SendPhoneOtpParams> {
  final AuthRepository repository;

  SendPhoneOtp(this.repository);

  @override
  Future<Either<Failure, void>> call(SendPhoneOtpParams params) async {
    return await repository.sendPhoneOtp(params.phoneNumber);
  }
}

class SendPhoneOtpParams extends Equatable {
  final String phoneNumber;

  const SendPhoneOtpParams({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}