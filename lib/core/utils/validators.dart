class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove any non-digit characters except +
    String cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check for Indian phone number patterns
    if (cleaned.startsWith('+91') && cleaned.length == 13) {
      String number = cleaned.substring(3);
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(number)) {
        return 'Please enter a valid Indian phone number';
      }
    } else if (cleaned.startsWith('91') && cleaned.length == 12) {
      String number = cleaned.substring(2);
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(number)) {
        return 'Please enter a valid Indian phone number';
      }
    } else if (cleaned.length == 10) {
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
        return 'Please enter a valid Indian phone number';
      }
    } else {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    
    if (age < 18) {
      return 'You must be at least 18 years old';
    }
    
    if (age > 100) {
      return 'Please enter a valid age';
    }
    
    return null;
  }

  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bio is required';
    }
    
    if (value.length < 10) {
      return 'Bio must be at least 10 characters long';
    }
    
    if (value.length > 500) {
      return 'Bio must be less than 500 characters';
    }
    
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    
    return null;
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters except +
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
}