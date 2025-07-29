import 'package:dio/dio.dart';

class SimpleApiClient {
  final Dio _dio;

  SimpleApiClient(this._dio) {
    // Note: API endpoints are commented out since we're using Firebase
    // _dio.options.baseUrl = 'https://your-api.com/v1';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Add error handling interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          print('API Error: ${error.message}');
          if (error.type == DioExceptionType.connectionError) {
            print('Connection Error Details: ${error.error}');
          }
          handler.next(error);
        },
        onRequest: (options, handler) {
          print('Making request to: ${options.uri}');
          handler.next(options);
        },
      ),
    );
  }

  // Authentication endpoints
  Future<Map<String, dynamic>> sendPhoneOtp(Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/phone/send-otp', data: body);
    return response.data;
  }

  Future<Map<String, dynamic>> verifyPhoneOtp(Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/phone/verify-otp', data: body);
    return response.data;
  }

  Future<Map<String, dynamic>> googleLogin(Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/social/google', data: body);
    return response.data;
  }

  Future<Map<String, dynamic>> facebookLogin(Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/social/facebook', data: body);
    return response.data;
  }

  // Profile endpoints
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/profile/me');
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    final response = await _dio.put('/profile/me', data: body);
    return response.data;
  }

  Future<Map<String, dynamic>> uploadPhoto(FormData formData) async {
    final response = await _dio.post('/profile/photos', data: formData);
    return response.data;
  }

  // Discovery endpoints
  Future<Map<String, dynamic>> getDiscoveryProfiles(int page, int limit) async {
    final response = await _dio.get('/discovery/profiles', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> swipeProfile(Map<String, dynamic> body) async {
    final response = await _dio.post('/discovery/swipe', data: body);
    return response.data;
  }

  // Matching endpoints
  Future<Map<String, dynamic>> getMatches() async {
    final response = await _dio.get('/matches');
    return response.data;
  }

  Future<Map<String, dynamic>> requestMeetup(String matchId, Map<String, dynamic> body) async {
    final response = await _dio.post('/matches/$matchId/meetup-request', data: body);
    return response.data;
  }

  // Payment endpoints
  Future<Map<String, dynamic>> createPaymentOrder(Map<String, dynamic> body) async {
    final response = await _dio.post('/payments/create-order', data: body);
    return response.data;
  }

  Future<Map<String, dynamic>> verifyPayment(Map<String, dynamic> body) async {
    final response = await _dio.post('/payments/verify', data: body);
    return response.data;
  }
}