enum UserType {
  male,
  female,
}

extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.male:
        return 'Male';
      case UserType.female:
        return 'Female';
    }
  }

  String get description {
    switch (this) {
      case UserType.male:
        return 'Looking for meaningful connections';
      case UserType.female:
        return 'Enjoy premium experiences for free';
    }
  }

  String get emoji {
    switch (this) {
      case UserType.male:
        return '👨';
      case UserType.female:
        return '👩';
    }
  }
}