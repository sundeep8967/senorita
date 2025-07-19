import '../../../../core/network/simple_api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendPhoneOtp(String phoneNumber);
  Future<UserModel> verifyPhoneOtp(String phoneNumber, String otp);
  Future<UserModel> loginWithGoogle(String idToken);
  Future<UserModel> loginWithFacebook(String accessToken);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SimpleApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> sendPhoneOtp(String phoneNumber) async {
    await apiClient.sendPhoneOtp({
      'phoneNumber': phoneNumber,
    });
  }

  @override
  Future<UserModel> verifyPhoneOtp(String phoneNumber, String otp) async {
    final response = await apiClient.verifyPhoneOtp({
      'phoneNumber': phoneNumber,
      'otp': otp,
    });
    
    return UserModel.fromJson(response['user']);
  }

  @override
  Future<UserModel> loginWithGoogle(String idToken) async {
    final response = await apiClient.googleLogin({
      'idToken': idToken,
    });
    
    return UserModel.fromJson(response['user']);
  }

  @override
  Future<UserModel> loginWithFacebook(String accessToken) async {
    final response = await apiClient.facebookLogin({
      'accessToken': accessToken,
    });
    
    return UserModel.fromJson(response['user']);
  }

  @override
  Future<void> logout() async {
    // Implement logout logic
    // This might involve calling a logout endpoint or just clearing local data
  }
}