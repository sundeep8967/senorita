import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConnectionTest {
  static Future<Map<String, dynamic>> testConnection() async {
    Map<String, dynamic> result = {
      'success': false,
      'message': '',
      'details': {},
    };

    try {
      // Check environment variables
      final supabaseUrl = dotenv.env['NEXT_PUBLIC_SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['NEXT_PUBLIC_SUPABASE_ANON_KEY'];
      
      result['details']['url'] = supabaseUrl;
      result['details']['hasKey'] = supabaseAnonKey != null;
      result['details']['keyLength'] = supabaseAnonKey?.length ?? 0;
      
      if (supabaseUrl == null || supabaseAnonKey == null) {
        result['message'] = 'Missing Supabase credentials in .env file';
        return result;
      }

      // Test if Supabase is already initialized
      try {
        final client = Supabase.instance.client;
        result['details']['alreadyInitialized'] = true;
        
        // Test connection by trying to access storage
        try {
          final buckets = await client.storage.listBuckets();
          result['details']['bucketsFound'] = buckets.length;
          result['details']['bucketNames'] = buckets.map((b) => b.name).toList();
          
          // Check for required buckets
          final bucketNames = buckets.map((b) => b.name).toList();
          final requiredBuckets = ['verification-images', 'profile-images'];
          Map<String, bool> bucketStatus = {};
          
          for (String bucketName in requiredBuckets) {
            bucketStatus[bucketName] = bucketNames.contains(bucketName);
          }
          
          result['details']['requiredBuckets'] = bucketStatus;
          result['success'] = true;
          result['message'] = 'Supabase connection successful!';
          
        } catch (storageError) {
          result['message'] = 'Supabase initialized but storage access failed: $storageError';
          result['details']['storageError'] = storageError.toString();
        }
        
      } catch (notInitializedError) {
        result['details']['alreadyInitialized'] = false;
        result['message'] = 'Supabase not initialized yet: $notInitializedError';
      }
      
    } catch (e) {
      result['message'] = 'Error testing Supabase connection: $e';
      result['details']['error'] = e.toString();
    }
    
    return result;
  }
  
  static void printTestResults(Map<String, dynamic> result) {
    print('🧪 ===== SUPABASE CONNECTION TEST =====');
    print('✅ Success: ${result['success']}');
    print('📝 Message: ${result['message']}');
    print('📊 Details:');
    
    final details = result['details'] as Map<String, dynamic>;
    details.forEach((key, value) {
      print('   $key: $value');
    });
    
    print('🧪 ===== END TEST =====');
  }
}