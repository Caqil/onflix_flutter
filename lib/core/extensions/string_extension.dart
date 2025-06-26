import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

extension StringExtension on String {
  // Validation extensions
  bool get isValidEmail {
    return RegExp(AppConstants.emailRegex).hasMatch(this);
  }

  bool get isValidPhone {
    return RegExp(AppConstants.phoneRegex).hasMatch(this);
  }

  bool get isValidPassword {
    return RegExp(AppConstants.passwordRegex).hasMatch(this);
  }

  bool get isValidUsername {
    return RegExp(AppConstants.usernameRegex).hasMatch(this);
  }

  // Text formatting
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  String get camelCase {
    if (isEmpty) return this;
    final words = split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;

    return words.first.toLowerCase() +
        words.skip(1).map((word) => word.capitalize).join();
  }

  String get pascalCase {
    if (isEmpty) return this;
    return split(RegExp(r'[\s_-]+')).map((word) => word.capitalize).join();
  }

  String get kebabCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '-${match.group(0)!.toLowerCase()}',
    ).replaceAll(RegExp(r'[\s_]+'), '-').toLowerCase();
  }

  String get snakeCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceAll(RegExp(r'[\s-]+'), '_').toLowerCase();
  }

  // Text manipulation
  String truncate(int length, {String suffix = '...'}) {
    if (this.length <= length) return this;
    return '${substring(0, length)}$suffix';
  }

  String get removeExtraWhitespace {
    return trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String get removeAllWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  String get reverseString {
    return split('').reversed.join();
  }

  // Content formatting
  String get formatDuration {
    final duration = int.tryParse(this);
    if (duration == null) return this;

    final hours = duration ~/ 60;
    final minutes = duration % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get formatFileSize {
    final bytes = int.tryParse(this);
    if (bytes == null) return this;

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[suffixIndex]}';
  }

  String get formatViewCount {
    final count = int.tryParse(this);
    if (count == null) return this;

    if (count >= 1000000000) {
      return '${(count / 1000000000).toStringAsFixed(1)}B views';
    } else if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M views';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K views';
    }
    return '$count views';
  }

  // URL and path utilities
  String get toUrlSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  bool get isValidUrl {
    try {
      final uri = Uri.parse(this);
      return uri.hasScheme && (uri.hasAuthority || uri.host.isNotEmpty);
    } catch (e) {
      return false;
    }
  }

  String get getFileExtension {
    final lastDot = lastIndexOf('.');
    if (lastDot == -1) return '';
    return substring(lastDot + 1).toLowerCase();
  }

  String get getFileName {
    final lastSlash = lastIndexOf('/');
    if (lastSlash == -1) return this;
    return substring(lastSlash + 1);
  }

  String get getFileNameWithoutExtension {
    final fileName = getFileName;
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return fileName;
    return fileName.substring(0, lastDot);
  }

  // JSON and encoding
  String get escape {
    return replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  String get unescape {
    return replaceAll('\\"', '"')
        .replaceAll('\\n', '\n')
        .replaceAll('\\r', '\r')
        .replaceAll('\\t', '\t');
  }

  // Color and theming
  String get toHex {
    if (startsWith('#')) return this;
    return '#$this';
  }

  bool get isHexColor {
    return RegExp(r'^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$').hasMatch(this);
  }

  // Search and matching
  bool containsIgnoreCase(String other) {
    return toLowerCase().contains(other.toLowerCase());
  }

  bool startsWithIgnoreCase(String other) {
    return toLowerCase().startsWith(other.toLowerCase());
  }

  bool endsWithIgnoreCase(String other) {
    return toLowerCase().endsWith(other.toLowerCase());
  }

  double similarityTo(String other) {
    if (this == other) return 1.0;
    if (isEmpty || other.isEmpty) return 0.0;

    final longer = length > other.length ? this : other;
    final shorter = length > other.length ? other : this;

    if (longer.isEmpty) return 1.0;

    final editDistance = _levenshteinDistance(longer, shorter);
    return (longer.length - editDistance) / longer.length;
  }

  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    final matrix = List.generate(
      len1 + 1,
      (i) => List.filled(len2 + 1, 0),
    );

    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  // Content type detection
  bool get isImageFile {
    final ext = getFileExtension;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'].contains(ext);
  }

  bool get isVideoFile {
    final ext = getFileExtension;
    return AppConstants.supportedVideoFormats.contains(ext);
  }

  bool get isAudioFile {
    final ext = getFileExtension;
    return AppConstants.supportedAudioFormats.contains(ext);
  }

  bool get isSubtitleFile {
    final ext = getFileExtension;
    return AppConstants.supportedSubtitleFormats.contains(ext);
  }

  // Masking and privacy
  String get maskEmail {
    if (!isValidEmail) return this;
    final parts = split('@');
    if (parts.length != 2) return this;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) return this;

    final maskedUsername = username[0] +
        '*' * (username.length - 2) +
        username[username.length - 1];

    return '$maskedUsername@$domain';
  }

  String get maskPhone {
    if (!isValidPhone) return this;
    if (length < 4) return this;

    return substring(0, 3) + '*' * (length - 6) + substring(length - 3);
  }

  String maskCreditCard() {
    final cleaned = replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 8) return this;

    return '*' * (cleaned.length - 4) + cleaned.substring(cleaned.length - 4);
  }
}

// Nullable string extensions
extension NullableStringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullAndNotEmpty => this != null && this!.isNotEmpty;

  String get orEmpty => this ?? '';
  String orDefault(String defaultValue) => this ?? defaultValue;

  String? get nullIfEmpty => isNullOrEmpty ? null : this;

  int get lengthOrZero => this?.length ?? 0;
}
