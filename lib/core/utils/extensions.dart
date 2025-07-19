import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  // Theme extensions
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  // MediaQuery extensions
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  
  // Navigation extensions
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> push<T>(Widget page) => Navigator.of(this).push<T>(
    MaterialPageRoute(builder: (_) => page),
  );
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(Widget page, {TO? result}) => Navigator.of(this).pushReplacement<T, TO>(
    MaterialPageRoute(builder: (_) => page),
    result: result,
  );
  Future<T?> pushAndRemoveUntil<T>(Widget page) => Navigator.of(this).pushAndRemoveUntil<T>(
    MaterialPageRoute(builder: (_) => page),
    (route) => false,
  );
  
  // Snackbar extensions
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
  
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.red);
  }
  
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }
}

extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
  
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }
  
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  bool get isValidPhoneNumber {
    String cleaned = replaceAll(RegExp(r'[^\d+]'), '');
    
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
}

extension ListExtensions<T> on List<T> {
  List<T> get unique {
    return toSet().toList();
  }
  
  T? get firstOrNull {
    return isEmpty ? null : first;
  }
  
  T? get lastOrNull {
    return isEmpty ? null : last;
  }
}

extension DateTimeExtensions on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
  
  String get formattedDate {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }
  
  String get formattedTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}