import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class PhoneService {
  /// Get all phone numbers from device SIMs
  static Future<List<String>> getAllPhoneNumbers() async {
    try {
      // Request phone permission
      final phonePermission = await Permission.phone.request();
      
      if (phonePermission.isGranted) {
        // Simulate detecting multiple SIM cards
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
        
        // For demonstration, return sample numbers for dual SIM
        // In real implementation, this would detect actual SIM cards
        return [
          '+91 98765 43210', // SIM 1
          '+91 87654 32109', // SIM 2
        ];
      }
      
      return [];
    } catch (e) {
      print('Error getting phone numbers: $e');
      return [];
    }
  }

  /// Get primary phone number (first detected SIM)
  static Future<String?> getPhoneNumber() async {
    try {
      final phoneNumbers = await getAllPhoneNumbers();
      return phoneNumbers.isNotEmpty ? phoneNumbers.first : null;
    } catch (e) {
      print('Error getting phone number: $e');
      return null;
    }
  }

  /// Get SIM card details with carrier info
  static Future<List<Map<String, dynamic>>> getSimDetails() async {
    try {
      final phonePermission = await Permission.phone.request();
      
      if (phonePermission.isGranted) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Simulate dual SIM with carrier info
        return [
          {
            'phoneNumber': '+91 98765 43210',
            'carrierName': 'Airtel',
            'slotIndex': 0,
            'displayName': 'SIM 1 - Airtel',
            'isActive': true,
          },
          {
            'phoneNumber': '+91 87654 32109',
            'carrierName': 'Jio',
            'slotIndex': 1,
            'displayName': 'SIM 2 - Jio',
            'isActive': true,
          },
        ];
      }
      
      return [];
    } catch (e) {
      print('Error getting SIM details: $e');
      return [];
    }
  }

  /// Get device information
  static Future<Map<String, dynamic>?> getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
          'localizedModel': iosInfo.localizedModel,
        };
      }
      
      return null;
    } catch (e) {
      print('Error getting device info: $e');
      return null;
    }
  }

  /// Check if device supports phone functionality
  static Future<bool> hasPhoneCapability() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        // Check if device has telephony features
        return androidInfo.systemFeatures.contains('android.hardware.telephony');
      }
      return Platform.isIOS; // iOS devices typically have phone capability
    } catch (e) {
      return false;
    }
  }

  /// Format phone number to standard format
  static String _formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // If it starts with country code, keep it
    if (cleaned.startsWith('+91')) {
      return cleaned;
    } else if (cleaned.startsWith('91') && cleaned.length == 12) {
      return '+$cleaned';
    } else if (cleaned.length == 10) {
      // Indian number without country code
      return '+91$cleaned';
    }
    
    return cleaned;
  }

  /// Validate Indian phone number
  static bool isValidIndianPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check for Indian phone number patterns
    if (cleaned.startsWith('+91') && cleaned.length == 13) {
      String number = cleaned.substring(3);
      return RegExp(r'^[6-9]\d{9}$').hasMatch(number);
    } else if (cleaned.startsWith('91') && cleaned.length == 12) {
      String number = cleaned.substring(2);
      return RegExp(r'^[6-9]\d{9}$').hasMatch(number);
    } else if (cleaned.length == 10) {
      return RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned);
    }
    
    return false;
  }

  /// Request necessary permissions
  static Future<bool> requestPermissions() async {
    final permissions = [
      Permission.phone,
      Permission.sms,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    return statuses[Permission.phone]?.isGranted ?? false;
  }
}