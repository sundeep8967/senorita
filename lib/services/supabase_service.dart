import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();
  
  static final String supabaseUrl = dotenv.env['NEXT_PUBLIC_SUPABASE_URL']!;
  static final String supabaseAnonKey = dotenv.env['NEXT_PUBLIC_SUPABASE_ANON_KEY']!;
  
  static bool _initialized = false;
  
  static Future<void> initialize() async {
    if (_initialized) return;
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _initialized = true;
    print('✅ Supabase initialized successfully');
  }
  
  SupabaseClient get client => Supabase.instance.client;
  
  /// Upload face verification image to Supabase Storage
  Future<String> uploadFaceImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      final fileName = 'face_verification_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${user.uid}/face_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      print('📸 Uploading face image to Supabase: $filePath');
      
      // Upload file to Supabase Storage
      await client.storage
          .from('senorita-images-bucket')
          .upload(filePath, imageFile);
      
      // Get public URL
      final publicUrl = client.storage
          .from('senorita-images-bucket')
          .getPublicUrl(filePath);
      
      print('✅ Face image uploaded successfully: $publicUrl');
      return publicUrl;
      
    } catch (e) {
      print('❌ Error uploading face image to Supabase: $e');
      throw Exception('Failed to upload face image: $e');
    }
  }
  
  /// Upload document verification image to Supabase Storage
  Future<String> uploadDocumentImage(File imageFile, String documentType) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      final fileName = '${documentType.toLowerCase()}_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${user.uid}/verification/${documentType.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      print('📄 Uploading document image to Supabase: $filePath');
      print('📄 User UID: ${user.uid}');
      print('📄 File size: ${await imageFile.length()} bytes');
      
      // Upload file to Supabase Storage
      await client.storage
          .from('senorita-images-bucket')
          .upload(filePath, imageFile);
      
      // Get public URL
      final publicUrl = client.storage
          .from('senorita-images-bucket')
          .getPublicUrl(filePath);
      
      print('✅ Document image uploaded successfully: $publicUrl');
      return publicUrl;
      
    } catch (e) {
      print('❌ Error uploading document image to Supabase: $e');
      throw Exception('Failed to upload document image: $e');
    }
  }
  
  /// Upload profile image to Supabase Storage
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      final fileName = 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${user.uid}/personal/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      print('👤 Uploading profile image to Supabase: $filePath');
      
      // Upload file to Supabase Storage
      await client.storage
          .from('senorita-images-bucket')
          .upload(filePath, imageFile);
      
      // Get public URL
      final publicUrl = client.storage
          .from('senorita-images-bucket')
          .getPublicUrl(filePath);
      
      print('✅ Profile image uploaded successfully: $publicUrl');
      return publicUrl;
      
    } catch (e) {
      print('❌ Error uploading profile image to Supabase: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }
  
  /// Delete image from Supabase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length < 3) {
        throw Exception('Invalid image URL format');
      }
      
      final bucket = pathSegments[pathSegments.length - 3];
      final filePath = pathSegments.sublist(pathSegments.length - 2).join('/');
      
      print('🗑️ Deleting image from Supabase: $bucket/$filePath');
      
      await client.storage
          .from('senorita-images-bucket')
          .remove([filePath]);
      
      print('✅ Image deleted successfully');
      
    } catch (e) {
      print('❌ Error deleting image from Supabase: $e');
      // Don't throw error for deletion failures
    }
  }
}