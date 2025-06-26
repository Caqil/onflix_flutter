import 'package:onflix/core/extensions/datetime_extension.dart';

import '../constants/app_constants.dart';
import '../extensions/string_extension.dart';

class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.isValidEmail) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? optionalEmail(String? value) {
    if (value == null || value.isEmpty) return null;
    return email(value);
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.isValidPassword) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? originalPassword) {
    final passwordError = password(value);
    if (passwordError != null) return passwordError;

    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Username validation
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (value.length > 20) {
      return 'Username cannot exceed 20 characters';
    }
    if (!value.isValidUsername) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  // Phone validation
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!value.isValidPhone) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? optionalPhone(String? value) {
    if (value == null || value.isEmpty) return null;
    return phone(value);
  }

  // Name validation
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (value.length > 50) {
      return 'Name cannot exceed 50 characters';
    }
    // if (!RegExp(r'^[a-zA-Z\s]+).hasMatch(value)) {
    //   return 'Name can only contain letters and spaces';
    // }
    return null;
  }

  static String? firstName(String? value) {
    return name(value);
  }

  static String? lastName(String? value) {
    return name(value);
  }

  // Generic required field validation
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Length validation
  static String? minLength(String? value, int minLength,
      {String fieldName = 'Field'}) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength,
      {String fieldName = 'Field'}) {
    if (value != null && value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    return null;
  }

  static String? lengthRange(String? value, int minLength, int maxLength,
      {String fieldName = 'Field'}) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    if (value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    return null;
  }

  // Number validation
  static String? number(String? value, {String fieldName = 'Number'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  static String? integer(String? value, {String fieldName = 'Number'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid whole number';
    }
    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = 'Number'}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;

    final num = double.parse(value!);
    if (num <= 0) {
      return '$fieldName must be positive';
    }
    return null;
  }

  static String? numberRange(String? value, double min, double max,
      {String fieldName = 'Number'}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;

    final num = double.parse(value!);
    if (num < min || num > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }

  // URL validation
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    if (!value.isValidUrl) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  static String? optionalUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    return url(value);
  }

  // Date validation
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  static String? futureDate(String? value) {
    final dateError = date(value);
    if (dateError != null) return dateError;

    final parsedDate = DateTime.parse(value!);
    if (parsedDate.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }
    return null;
  }

  static String? pastDate(String? value) {
    final dateError = date(value);
    if (dateError != null) return dateError;

    final parsedDate = DateTime.parse(value!);
    if (parsedDate.isAfter(DateTime.now())) {
      return 'Date must be in the past';
    }
    return null;
  }

  static String? dateOfBirth(String? value) {
    final dateError = pastDate(value);
    if (dateError != null) return dateError;

    final dob = DateTime.parse(value!);
    final age = dob.age;

    if (age < 13) {
      return 'You must be at least 13 years old';
    }
    if (age > 120) {
      return 'Please enter a valid date of birth';
    }
    return null;
  }

  // Credit card validation
  static String? creditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Credit card number is required';
    }

    final cleanValue = value.replaceAll(RegExp(r'\D'), '');

    if (cleanValue.length < 13 || cleanValue.length > 19) {
      return 'Please enter a valid credit card number';
    }

    if (!_luhnCheck(cleanValue)) {
      return 'Please enter a valid credit card number';
    }

    return null;
  }

  static bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cardNumber[i]);

      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }

      sum += n;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  static String? cvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'Please enter a valid CVV';
    }
    return null;
  }

  static String? expiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }

    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return 'Please enter date in MM/YY format';
    }

    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null || month < 1 || month > 12) {
      return 'Please enter a valid expiry date';
    }

    final now = DateTime.now();
    final expiry = DateTime(2000 + year, month);

    if (expiry.isBefore(DateTime(now.year, now.month))) {
      return 'Card has expired';
    }

    return null;
  }

  // Content-specific validation
  static String? contentTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length < 2) {
      return 'Title must be at least 2 characters long';
    }
    if (value.length > 100) {
      return 'Title cannot exceed 100 characters';
    }
    return null;
  }

  static String? contentDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    if (value.length < 10) {
      return 'Description must be at least 10 characters long';
    }
    if (value.length > 1000) {
      return 'Description cannot exceed 1000 characters';
    }
    return null;
  }

  static String? duration(String? value) {
    if (value == null || value.isEmpty) {
      return 'Duration is required';
    }
    final duration = int.tryParse(value);
    if (duration == null || duration <= 0) {
      return 'Please enter a valid duration in minutes';
    }
    if (duration > 600) {
      // 10 hours
      return 'Duration cannot exceed 600 minutes';
    }
    return null;
  }

  static String? rating(String? value) {
    if (value == null || value.isEmpty) return null;
    final rating = double.tryParse(value);
    if (rating == null || rating < 0 || rating > 10) {
      return 'Rating must be between 0 and 10';
    }
    return null;
  }

  // Profile validation
  static String? profileName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Profile name is required';
    }
    if (value.length < 2) {
      return 'Profile name must be at least 2 characters long';
    }
    if (value.length > 30) {
      return 'Profile name cannot exceed 30 characters';
    }
    return null;
  }

  static String? parentalPin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return 'PIN must be 4 digits';
    }
    return null;
  }

  // Subscription validation
  static String? subscriptionPlan(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a subscription plan';
    }
    if (!AppConstants.subscriptionPlans.contains(value)) {
      return 'Please select a valid subscription plan';
    }
    return null;
  }

  // File validation
  static String? fileSize(int? sizeInBytes, int maxSizeInMB) {
    if (sizeInBytes == null) {
      return 'File size is required';
    }
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    if (sizeInBytes > maxSizeInBytes) {
      return 'File size cannot exceed ${maxSizeInMB}MB';
    }
    return null;
  }

  static String? imageFile(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return 'Please select an image file';
    }
    if (!fileName.isImageFile) {
      return 'Please select a valid image file (JPG, PNG, GIF, WebP)';
    }
    return null;
  }

  static String? videoFile(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return 'Please select a video file';
    }
    if (!fileName.isVideoFile) {
      return 'Please select a valid video file';
    }
    return null;
  }

  // Custom validators
  static String? Function(String?) custom(
    bool Function(String?) validator,
    String errorMessage,
  ) {
    return (value) => validator(value) ? null : errorMessage;
  }

  static String? Function(String?) regex(
    RegExp pattern,
    String errorMessage,
  ) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      return pattern.hasMatch(value) ? null : errorMessage;
    };
  }

  // Combination validators
  static String? Function(String?) combine(
      List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  // Async validation helpers
  static Future<String?> asyncEmail(String? value) async {
    final basicValidation = email(value);
    if (basicValidation != null) return basicValidation;

    // Add your async email validation logic here
    // e.g., check if email already exists
    await Future.delayed(const Duration(milliseconds: 500));
    return null;
  }

  static Future<String?> asyncUsername(String? value) async {
    final basicValidation = username(value);
    if (basicValidation != null) return basicValidation;

    // Add your async username validation logic here
    // e.g., check if username is available
    await Future.delayed(const Duration(milliseconds: 500));
    return null;
  }
}
