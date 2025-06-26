import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../extensions/string_extension.dart';
import '../extensions/datetime_extension.dart';

class Formatters {
  // Private constructor to prevent instantiation
  Formatters._();
  
  // Number formatters
  static String formatCurrency(double amount, {String? currencySymbol}) {
    final formatter = NumberFormat.currency(
      symbol: currencySymbol ?? '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
  
  static String formatNumber(num number, {int? decimalPlaces}) {
    if (decimalPlaces != null) {
      return number.toStringAsFixed(decimalPlaces);
    }
    return NumberFormat('#,##0.##').format(number);
  }
  
  static String formatPercentage(double value, {int decimalPlaces = 1}) {
    return '${(value * 100).toStringAsFixed(decimalPlaces)}%';
  }
  
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var suffixIndex = 0;
    
    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }
    
    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${suffixes[suffixIndex]}';
  }
  
  static String formatViewCount(int count) {
    if (count >= 1000000000) {
      return '${(count / 1000000000).toStringAsFixed(1)}B';
    } else if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
  
  // Duration formatters
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
             '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    }
  }
  
  static String formatDurationFromSeconds(int seconds) {
    return formatDuration(Duration(seconds: seconds));
  }
  
  static String formatDurationFromMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    }
    return '${remainingMinutes}m';
  }
  
  static String formatRemainingTime(Duration remaining) {
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours.remainder(24)}h remaining';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m remaining';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m remaining';
    } else {
      return '${remaining.inSeconds}s remaining';
    }
  }
  
  // Date formatters
  static String formatDate(DateTime date, {String? pattern}) {
    final formatter = DateFormat(pattern ?? 'MMM d, yyyy');
    return formatter.format(date);
  }
  
  static String formatTime(DateTime time, {bool use24Hour = false}) {
    final pattern = use24Hour ? 'HH:mm' : 'h:mm a';
    return DateFormat(pattern).format(time);
  }
  
  static String formatDateTime(DateTime dateTime, {String? pattern}) {
    final formatter = DateFormat(pattern ?? 'MMM d, yyyy h:mm a');
    return formatter.format(dateTime);
  }
  
  static String formatRelativeDate(DateTime date) {
    return date.relativeTime;
  }
  
  static String formatTimeAgo(DateTime date) {
    return date.timeAgo;
  }
  
  // Content formatters
  static String formatContentDuration(int? durationInMinutes) {
    if (durationInMinutes == null) return '';
    return formatDurationFromMinutes(durationInMinutes);
  }
  
  static String formatRating(double? rating) {
    if (rating == null) return 'Not Rated';
    return '${(rating * 10).toInt()}% Match';
  }
  
  static String formatMaturityRating(String? rating) {
    if (rating == null || rating.isEmpty) return '';
    return rating.toUpperCase();
  }
  
  static String formatGenres(List<String> genres, {int maxGenres = 3}) {
    if (genres.isEmpty) return '';
    final displayGenres = genres.take(maxGenres).toList();
    final result = displayGenres.join(', ');
    if (genres.length > maxGenres) {
      return '$result +${genres.length - maxGenres} more';
    }
    return result;
  }
  
  static String formatCast(List<String> cast, {int maxCast = 3}) {
    if (cast.isEmpty) return '';
    final displayCast = cast.take(maxCast).toList();
    final result = displayCast.join(', ');
    if (cast.length > maxCast) {
      return '$result and ${cast.length - maxCast} others';
    }
    return result;
  }
  
  static String formatReleaseYear(DateTime? releaseDate) {
    if (releaseDate == null) return '';
    return releaseDate.year.toString();
  }
  
  // Phone number formatter
  static String formatPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 11 && cleaned.startsWith('1')) {
      return '+1 (${cleaned.substring(1, 4)}) ${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    }
    
    return phoneNumber;
  }
  
  // Credit card formatters
  static String formatCreditCard(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    
    return buffer.toString();
  }
  
  static String maskCreditCard(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 4) return cardNumber;
    
    final lastFour = cleaned.substring(cleaned.length - 4);
    final masked = '*' * (cleaned.length - 4);
    return formatCreditCard('$masked$lastFour');
  }
  
  static String formatExpiryDate(String expiryDate) {
    final cleaned = expiryDate.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length >= 2) {
      final month = cleaned.substring(0, 2);
      final year = cleaned.length >= 4 ? cleaned.substring(2, 4) : '';
      return year.isNotEmpty ? '$month/$year' : month;
    }
    return cleaned;
  }
  
  // URL formatters
  static String formatUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }
  
  static String formatDisplayUrl(String url) {
    return url.replaceFirst(RegExp(r'https?://'), '').replaceFirst('www.', '');
  }
  
  // Text formatters
  static String formatTitle(String title) {
    return title.titleCase;
  }
  
  static String formatSlug(String text) {
    return text.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
  
  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    return text.truncate(maxLength, suffix: suffix);
  }
  
  static String capitalizeFirstLetter(String text) {
    return text.capitalize;
  }
  
  static String formatSentence(String text) {
    if (text.isEmpty) return text;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    
    final firstChar = trimmed[0].toUpperCase();
    final rest = trimmed.length > 1 ? trimmed.substring(1) : '';
    final result = '$firstChar$rest';
    
    if (!result.endsWith('.') && !result.endsWith('!') && !result.endsWith('?')) {
      return '$result.';
    }
    
    return result;
  }
  
  // Search formatters
  static String formatSearchQuery(String query) {
    return query.trim().toLowerCase();
  }
  
  static String highlightSearchTerm(String text, String searchTerm) {
    if (searchTerm.isEmpty) return text;
    
    final regex = RegExp(RegExp.escape(searchTerm), caseSensitive: false);
    return text.replaceAllMapped(regex, (match) => '<mark>${match.group(0)}</mark>');
  }
  
  // Distance and location formatters
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()}m';
    } else if (distanceInKm < 100) {
      return '${distanceInKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceInKm.round()}km';
    }
  }
  
  // Download progress formatter
  static String formatDownloadProgress(int downloaded, int total) {
    final percentage = (downloaded / total * 100).toInt();
    final downloadedSize = formatFileSize(downloaded);
    final totalSize = formatFileSize(total);
    return '$percentage% ($downloadedSize / $totalSize)';
  }
  
  // Quality formatter
  static String formatQuality(String quality) {
    switch (quality.toLowerCase()) {
      case '240p':
        return 'Low (240p)';
      case '360p':
        return 'Medium (360p)';
      case '480p':
        return 'Standard (480p)';
      case '720p':
        return 'HD (720p)';
      case '1080p':
        return 'Full HD (1080p)';
      case '1440p':
        return '2K (1440p)';
      case '2160p':
        return '4K (2160p)';
      default:
        return quality;
    }
  }
  
  // Bitrate formatter
  static String formatBitrate(int bitrate) {
    if (bitrate >= 1000) {
      return '${(bitrate / 1000).toStringAsFixed(1)} Mbps';
    }
    return '$bitrate Kbps';
  }
  
  // Subscription formatter
  static String formatSubscriptionPlan(String plan) {
    switch (plan.toLowerCase()) {
      case 'basic':
        return 'Basic Plan';
      case 'standard':
        return 'Standard Plan';
      case 'premium':
        return 'Premium Plan';
      case 'family':
        return 'Family Plan';
      case 'student':
        return 'Student Plan';
      default:
        return plan.titleCase;
    }
  }
  
  // Privacy formatters
  static String maskEmail(String email) {
    return email.maskEmail;
  }
  
  static String maskPhoneNumber(String phoneNumber) {
    return phoneNumber.maskPhone;
  }
}