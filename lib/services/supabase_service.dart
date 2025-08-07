import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart' as supabase;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();
  
  static final String supabaseUrl = dotenv.env['NEXT_PUBLIC_SUPABASE_URL']!;
  static final String supabaseAnonKey = dotenv.env['NEXT_PUBLIC_SUPABASE_ANON_KEY']!;
  static final String? supabaseServiceKey = dotenv.env['SUPABASE_SERVICE_KEY'];
  
  static bool _initialized = false;
  static supabase.SupabaseClient? _serviceClient;
  
  static Future<void> initialize() async {
    if (_initialized) return;
    
    // Initialize regular Supabase client with anon key
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    
    // Create separate service client with service role key
    if (supabaseServiceKey != null) {
      _serviceClient = supabase.SupabaseClient(
        supabaseUrl,
        supabaseServiceKey!,
      );
    }
    
    _initialized = true;
    print('✅ Supabase initialized successfully');
    print('✅ Service client created with elevated access');
  }
  
  // Regular client for user operations
  SupabaseClient get client => Supabase.instance.client;
  
  // Service client for admin operations
  supabase.SupabaseClient get serviceClient {
    if (_serviceClient == null) {
      throw Exception('Service client not initialized. Service role key may be missing.');
    }
    return _serviceClient!;
  }
  
  /// Create user directory structure if it doesn't exist
  Future<void> _ensureUserDirectory(String userId) async {
    try {
      // Create an empty file to ensure the directory structure exists
      // Supabase Storage doesn't have explicit directory creation
      // We create a placeholder file in each directory
      
      final placeholder = utf8.encode('placeholder');
      
      // Create personal directory placeholder
      final personalPath = '$userId/personal/.keep';
      await serviceClient.storage
          .from('senorita-images-bucket')
          .uploadBinary(
            personalPath,
            placeholder,
            fileOptions: supabase.FileOptions(
              contentType: 'text/plain',
              upsert: true,
            ),
          );
      
      // Create verification directory placeholder
      final verificationPath = '$userId/verification/.keep';
      await serviceClient.storage
          .from('senorita-images-bucket')
          .uploadBinary(
            verificationPath,
            placeholder,
            fileOptions: supabase.FileOptions(
              contentType: 'text/plain',
              upsert: true,
            ),
          );
      
      print('✅ User directory structure created for: $userId');
    } catch (e) {
      // Ignore errors if directories already exist
      print('ℹ️ User directory already exists or creation failed: $e');
    }
  }
  
  /// Upload image directly to Supabase Storage using service role privileges
  Future<String> _uploadImageDirectly(File imageFile, String folder, String userId, {String? documentType}) async {
    try {
      // Ensure user directory structure exists
      await _ensureUserDirectory(userId);
      
      final bytes = await imageFile.readAsBytes();
      final fileName = documentType != null
          ? '${documentType.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : '${folder == 'verification' ? 'face' : 'profile'}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/$folder/$fileName';
      print('📤 Uploading directly to Supabase Storage: $filePath');
      
      // Use service client to bypass RLS
      final response = await serviceClient.storage
          .from('senorita-images-bucket')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: supabase.FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );
      
      if (response == null) {
        throw Exception('Upload failed: No response from server');
      }
      
      // Get public URL
      final publicUrl = serviceClient.storage
          .from('senorita-images-bucket')
          .getPublicUrl(filePath);
      
      print('✅ Direct upload successful: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading directly to Supabase: $e');
      throw Exception('Failed to upload image directly: $e');
    }
  }
  
  /// Upload face verification image
  Future<String> uploadFaceImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      print('📸 Uploading face image directly to Supabase Storage');
      print('🔐 Using Firebase UID: ${user.uid}');
      
      return await _uploadImageDirectly(imageFile, 'verification', user.uid);
      
    } catch (e) {
      print('❌ Error uploading face image: $e');
      throw Exception('Failed to upload face image: $e');
    }
  }
  
  /// Upload document verification image
  Future<String> uploadDocumentImage(File imageFile, String documentType) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      print('📄 Uploading document image directly to Supabase Storage');
      print('📄 User UID: ${user.uid}');
      print('📄 Document Type: $documentType');
      print('📄 File size: ${await imageFile.length()} bytes');
      
      return await _uploadImageDirectly(
        imageFile, 
        'verification', 
        user.uid, 
        documentType: documentType
      );
      
    } catch (e) {
      print('❌ Error uploading document image: $e');
      throw Exception('Failed to upload document image: $e');
    }
  }
  
  /// Upload profile image
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      print('👤 Uploading profile image directly to Supabase Storage');
      print('🔐 Using Firebase UID: ${user.uid}');
      
      return await _uploadImageDirectly(imageFile, 'personal', user.uid);
      
    } catch (e) {
      print('❌ Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }
  
  /// Delete image from Supabase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length < 3) {
        print('❌ Invalid image URL format');
        return false;
      }
      
      // The bucket name is the third segment from the end
      final bucketIndex = pathSegments.length - 3;
      final bucket = pathSegments[bucketIndex];
      
      // The file path is the last two segments joined
      final filePath = pathSegments.sublist(pathSegments.length - 2).join('/');
      
      print('🗑️ Deleting image from Supabase: $bucket/$filePath');
      
      // Fix typo in bucket name
      final bucketName = bucket == 'senorita-mages-bucket' 
          ? 'senorita-images-bucket' 
          : bucket;
      
      // Remove the file
      final removedFiles = await serviceClient.storage
          .from(bucketName)
          .remove([filePath]);
      
      // Check result
      if (removedFiles.isEmpty) {
        print('⚠️ No files were removed. File might not exist.');
        return false;
      } else {
        print('✅ Image deleted successfully: ${removedFiles.first.name}');
        return true;
      }
      
    } catch (e) {
      print('❌ Error deleting image from Supabase: $e');
      return false;
    }
  }
  
  /// Get all images for a specific user
  Future<Map<String, List<String>>> getUserImages(String userId) async {
    try {
      final result = <String, List<String>>{
        'personal': [],
        'verification': [],
      };
      
      // Get personal images
      final personalPath = '$userId/personal/';
      final personalList = await serviceClient.storage
          .from('senorita-images-bucket')
          .list(path: personalPath);
      
      for (final file in personalList) {
        if (file.name != '.keep') { // Skip placeholder
          final publicUrl = serviceClient.storage
              .from('senorita-images-bucket')
              .getPublicUrl('$personalPath${file.name}');
          result['personal']!.add(publicUrl);
        }
      }
      
      // Get verification images
      final verificationPath = '$userId/verification/';
      final verificationList = await serviceClient.storage
          .from('senorita-images-bucket')
          .list(path: verificationPath);
      
      for (final file in verificationList) {
        if (file.name != '.keep') { // Skip placeholder
          final publicUrl = serviceClient.storage
              .from('senorita-images-bucket')
              .getPublicUrl('$verificationPath${file.name}');
          result['verification']!.add(publicUrl);
        }
      }
      
      return result;
    } catch (e) {
      print('❌ Error getting user images: $e');
      return {'personal': [], 'verification': []};
    }
  }
}