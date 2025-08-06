import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
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
  
  static Future<void> initialize() async {
    if (_initialized) return;
    
    // Use anon key for limited access
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _initialized = true;
    print('✅ Supabase initialized successfully with anon key (upload-only access)');
  }
  
  SupabaseClient get client => Supabase.instance.client;
  
  /// Upload image via Edge Function (secure with service key)
  Future<String> _uploadViaEdgeFunction(File imageFile, String folder, String userId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileName = '${folder == 'verification' ? 'face' : 'profile'}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$supabaseUrl/functions/v1/upload-image'),
      );
      
      request.headers.addAll({
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'multipart/form-data',
      });
      
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      ));
      
      request.fields['folder'] = folder; // 'verification' or 'personal'
      request.fields['userId'] = userId; // Firebase UID
      
      print('📤 Uploading via Edge Function: $userId/$folder/$fileName');
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final result = json.decode(responseBody);
        print('✅ Upload successful: ${result['url']}');
        print('📁 Stored at: $userId/$folder/$fileName');
        return result['url'];
      } else {
        throw Exception('Upload failed: $responseBody');
      }
      
    } catch (e) {
      print('❌ Error uploading via Edge Function: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
  
  /// Upload face verification image via Edge Function
  Future<String> uploadFaceImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      print('📸 Uploading face image via Edge Function');
      print('🔐 Using Firebase UID: ${user.uid}');
      
      return await _uploadViaEdgeFunction(imageFile, 'verification', user.uid);
      
    } catch (e) {
      print('❌ Error uploading face image: $e');
      throw Exception('Failed to upload face image: $e');
    }
  }
  
  /// Upload document verification image via Edge Function
  Future<String> uploadDocumentImage(File imageFile, String documentType) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      print('📄 Uploading document image via Edge Function');
      print('📄 User UID: ${user.uid}');
      print('📄 Document Type: $documentType');
      print('📄 File size: ${await imageFile.length()} bytes');
      
      // Use a special method for documents to include document type in filename
      return await _uploadDocumentViaEdgeFunction(imageFile, documentType, user.uid);
      
    } catch (e) {
      print('❌ Error uploading document image: $e');
      throw Exception('Failed to upload document image: $e');
    }
  }
  
  /// Upload document with specific document type in filename
  Future<String> _uploadDocumentViaEdgeFunction(File imageFile, String documentType, String userId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileName = '${documentType.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$supabaseUrl/functions/v1/upload-image'),
      );
      
      request.headers.addAll({
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'multipart/form-data',
      });
      
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      ));
      
      request.fields['folder'] = 'verification';
      request.fields['userId'] = userId;
      request.fields['documentType'] = documentType;
      
      print('📤 Uploading document via Edge Function: $userId/verification/$fileName');
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final result = json.decode(responseBody);
        print('✅ Document upload successful: ${result['url']}');
        print('📁 Stored at: $userId/verification/$fileName');
        return result['url'];
      } else {
        throw Exception('Document upload failed: $responseBody');
      }
      
    } catch (e) {
      print('❌ Error uploading document via Edge Function: $e');
      throw Exception('Failed to upload document: $e');
    }
  }
  
  /// Upload profile image via Edge Function
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      print('👤 Uploading profile image via Edge Function');
      print('🔐 Using Firebase UID: ${user.uid}');
      
      return await _uploadViaEdgeFunction(imageFile, 'personal', user.uid);
      
    } catch (e) {
      print('❌ Error uploading profile image: $e');
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
          .from('senorita-mages-bucket')
          .remove([filePath]);
      
      print('✅ Image deleted successfully');
      
    } catch (e) {
      print('❌ Error deleting image from Supabase: $e');
      // Don't throw error for deletion failures
    }
  }
}