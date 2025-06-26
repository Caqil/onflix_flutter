import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Helpers {
  // Private constructor to prevent instantiation
  Helpers._();

  // String utilities
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = math.Random();
    return String.fromCharCodes(
      Iterable.generate(
          length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  static String generateId() {
    return generateRandomString(16);
  }

  static String generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = generateRandomString(8);
    return '${timestamp}_$random';
  }

  // Hash utilities
  static String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String hashPassword(String password, String salt) {
    return hashString('$password$salt');
  }

  static String generateSalt() {
    return generateRandomString(32);
  }

  // Color utilities
  static String getRandomColor() {
    final random = math.Random();
    return '#${random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }

  static String getContrastingColor(String hexColor) {
    final color = hexColor.replaceFirst('#', '');
    final r = int.parse(color.substring(0, 2), radix: 16);
    final g = int.parse(color.substring(2, 4), radix: 16);
    final b = int.parse(color.substring(4, 6), radix: 16);

    final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    return luminance > 0.5 ? '#000000' : '#FFFFFF';
  }

  // Math utilities
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  static double clamp(double value, double min, double max) {
    return math.max(min, math.min(max, value));
  }

  static int randomInt(int min, int max) {
    final random = math.Random();
    return min + random.nextInt(max - min + 1);
  }

  static double randomDouble(double min, double max) {
    final random = math.Random();
    return min + random.nextDouble() * (max - min);
  }

  // List utilities
  static T randomElement<T>(List<T> list) {
    if (list.isEmpty) throw ArgumentError('List cannot be empty');
    final random = math.Random();
    return list[random.nextInt(list.length)];
  }

  static List<T> shuffle<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    shuffled.shuffle();
    return shuffled;
  }

  static List<T> unique<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<List<T>> chunk<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, math.min(i + size, list.length)));
    }
    return chunks;
  }

  // Date utilities
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  static bool isWorkday(DateTime date) {
    return !isWeekend(date);
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }

  static DateTime addBusinessDays(DateTime date, int days) {
    var result = date;
    var remainingDays = days;

    while (remainingDays > 0) {
      result = result.add(const Duration(days: 1));
      if (isWorkday(result)) {
        remainingDays--;
      }
    }

    return result;
  }

  // URL utilities
  static Map<String, String> parseQueryString(String query) {
    final params = <String, String>{};
    if (query.isEmpty) return params;

    query.split('&').forEach((param) {
      final parts = param.split('=');
      if (parts.length == 2) {
        params[Uri.decodeComponent(parts[0])] = Uri.decodeComponent(parts[1]);
      }
    });

    return params;
  }

  static String buildQueryString(Map<String, dynamic> params) {
    if (params.isEmpty) return '';

    return params.entries
        .where((entry) => entry.value != null)
        .map((entry) =>
            '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');
  }

  // Device utilities
  static String getUserAgent() {
    // This would typically be platform-specific
    return 'Onflix/1.0.0 (Flutter)';
  }

  static String getDeviceId() {
    // Generate a unique device identifier
    return hashString(
        '${DateTime.now().millisecondsSinceEpoch}_${generateRandomString(16)}');
  }

  // File utilities
  static String getFileExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return '';
    return fileName.substring(lastDot + 1).toLowerCase();
  }

  static String getMimeType(String fileName) {
    final extension = getFileExtension(fileName);

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      case 'mp4':
        return 'video/mp4';
      case 'webm':
        return 'video/webm';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'ogg':
        return 'audio/ogg';
      case 'pdf':
        return 'application/pdf';
      case 'json':
        return 'application/json';
      case 'xml':
        return 'application/xml';
      case 'txt':
        return 'text/plain';
      case 'html':
        return 'text/html';
      case 'css':
        return 'text/css';
      case 'js':
        return 'application/javascript';
      default:
        return 'application/octet-stream';
    }
  }

  // Content utilities
  static String getContentTypeIcon(String contentType) {
    switch (contentType.toLowerCase()) {
      case AppConstants.movieType:
        return '🎬';
      case AppConstants.seriesType:
        return '📺';
      case AppConstants.documentaryType:
        return '📄';
      default:
        return '🎥';
    }
  }

  static String getMaturityRatingColor(String? rating) {
    if (rating == null) return '#808080';

    switch (rating.toUpperCase()) {
      case 'G':
      case 'TV-Y':
      case 'TV-G':
        return '#4CAF50'; // Green
      case 'PG':
      case 'TV-Y7':
      case 'TV-PG':
        return '#FF9800'; // Orange
      case 'PG-13':
      case 'TV-14':
        return '#FF5722'; // Deep Orange
      case 'R':
      case 'TV-MA':
        return '#F44336'; // Red
      case 'NC-17':
        return '#9C27B0'; // Purple
      default:
        return '#808080'; // Gray
    }
  }

  // Search utilities
  static double calculateRelevanceScore(String searchTerm, String content) {
    if (searchTerm.isEmpty || content.isEmpty) return 0.0;

    final searchLower = searchTerm.toLowerCase();
    final contentLower = content.toLowerCase();

    // Exact match gets highest score
    if (contentLower == searchLower) return 1.0;

    // Starts with search term gets high score
    if (contentLower.startsWith(searchLower)) return 0.9;

    // Contains search term gets medium score
    if (contentLower.contains(searchLower)) return 0.7;

    // Word boundary matches get lower score
    final words = contentLower.split(' ');
    for (final word in words) {
      if (word.startsWith(searchLower)) return 0.6;
      if (word.contains(searchLower)) return 0.4;
    }

    // Fuzzy matching for similar strings
    return _calculateStringSimilarity(searchLower, contentLower) * 0.3;
  }

  static double _calculateStringSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final longer = s1.length > s2.length ? s1 : s2;
    final shorter = s1.length > s2.length ? s2 : s1;

    if (longer.isEmpty) return 1.0;

    final editDistance = _levenshteinDistance(longer, shorter);
    return (longer.length - editDistance) / longer.length;
  }

  static int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    final matrix = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

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
        ].reduce(math.min);
      }
    }

    return matrix[len1][len2];
  }

  // Analytics utilities
  static Map<String, dynamic> getAnalyticsMetadata() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'sessionId': generateSessionId(),
      'userAgent': getUserAgent(),
      'platform': 'flutter',
      'version': AppConstants.appVersion,
    };
  }

  // Performance utilities
  static T withTiming<T>(String operation, T Function() function) {
    final stopwatch = Stopwatch()..start();
    final result = function();
    stopwatch.stop();
    print('$operation took ${stopwatch.elapsedMilliseconds}ms');
    return result;
  }

  static Future<T> withTimingAsync<T>(
      String operation, Future<T> Function() function) async {
    final stopwatch = Stopwatch()..start();
    final result = await function();
    stopwatch.stop();
    print('$operation took ${stopwatch.elapsedMilliseconds}ms');
    return result;
  }

  // Debouncing utility
  static void Function() debounce(void Function() function, Duration delay) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, function);
    };
  }

  // Throttling utility
  static void Function() throttle(void Function() function, Duration interval) {
    bool canExecute = true;
    return () {
      if (canExecute) {
        function();
        canExecute = false;
        Timer(interval, () => canExecute = true);
      }
    };
  }
}
