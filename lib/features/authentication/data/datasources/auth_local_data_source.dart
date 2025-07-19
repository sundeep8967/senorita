import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCachedUser();
  Future<String?> getAuthToken();
  Future<void> saveAuthToken(String token);
  Future<void> clearAuthToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = sharedPreferences.getString(AppConstants.userProfileKey);
    if (jsonString != null) {
      final jsonMap = json.decode(jsonString);
      return UserModel.fromJson(jsonMap);
    }
    return null;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final jsonString = json.encode(user.toJson());
    await sharedPreferences.setString(AppConstants.userProfileKey, jsonString);
  }

  @override
  Future<void> clearCachedUser() async {
    await sharedPreferences.remove(AppConstants.userProfileKey);
  }

  @override
  Future<String?> getAuthToken() async {
    return sharedPreferences.getString(AppConstants.authTokenKey);
  }

  @override
  Future<void> saveAuthToken(String token) async {
    await sharedPreferences.setString(AppConstants.authTokenKey, token);
  }

  @override
  Future<void> clearAuthToken() async {
    await sharedPreferences.remove(AppConstants.authTokenKey);
  }
}