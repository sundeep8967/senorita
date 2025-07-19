class AppConstants {
  // App Info
  static const String appName = 'Senorita';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'https://api.senorita.com';
  static const String apiVersion = '/v1';
  
  // Payment
  static const int basicMeetupPrice = 500;
  static const int premiumMeetupPrice = 1000;
  static const int luxuryMeetupPrice = 2000;
  
  // Razorpay
  static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY_ID';
  
  // Firebase
  static const String firebaseProjectId = 'senorita-dating-app';
  
  // Google Maps
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  
  // Agora (Video Calls)
  static const String agoraAppId = 'YOUR_AGORA_APP_ID';
  
  // App Limits
  static const int maxPhotosPerProfile = 6;
  static const int maxBioLength = 500;
  static const int minAge = 18;
  static const int maxAge = 60;
  static const double maxDistanceKm = 100.0;
  
  // Cache Keys
  static const String userProfileKey = 'user_profile';
  static const String userPreferencesKey = 'user_preferences';
  static const String authTokenKey = 'auth_token';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
}