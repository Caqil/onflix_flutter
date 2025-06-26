import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  // Formatting
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String get relativeTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final thisDate = DateTime(year, month, day);

    if (thisDate == today) {
      return 'Today';
    } else if (thisDate == yesterday) {
      return 'Yesterday';
    } else if (thisDate == tomorrow) {
      return 'Tomorrow';
    } else if (difference(now).inDays.abs() < 7) {
      return DateFormat('EEEE').format(this); // Monday, Tuesday, etc.
    } else if (year == now.year) {
      return DateFormat('MMM d').format(this); // Jan 15
    } else {
      return DateFormat('MMM d, yyyy').format(this); // Jan 15, 2023
    }
  }

  String formatAs(String pattern) {
    return DateFormat(pattern).format(this);
  }

  String get shortDate => DateFormat('MM/dd/yyyy').format(this);
  String get longDate => DateFormat('MMMM d, yyyy').format(this);
  String get shortTime => DateFormat('h:mm a').format(this);
  String get longTime => DateFormat('h:mm:ss a').format(this);
  String get shortDateTime => DateFormat('MM/dd/yyyy h:mm a').format(this);
  String get longDateTime => DateFormat('MMMM d, yyyy h:mm a').format(this);
  String get isoString => toIso8601String();

  // Date calculations
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }

  DateTime get endOfWeek => startOfWeek.add(const Duration(days: 6)).endOfDay;
  DateTime get startOfMonth => DateTime(year, month);
  DateTime get endOfMonth =>
      DateTime(year, month + 1).subtract(const Duration(days: 1)).endOfDay;
  DateTime get startOfYear => DateTime(year);
  DateTime get endOfYear => DateTime(year, 12, 31).endOfDay;

  // Comparisons
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfThisWeek = now.startOfWeek;
    final endOfThisWeek = now.endOfWeek;
    return isAfter(startOfThisWeek.subtract(const Duration(milliseconds: 1))) &&
        isBefore(endOfThisWeek.add(const Duration(milliseconds: 1)));
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  bool get isThisYear {
    final now = DateTime.now();
    return year == now.year;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameWeek(DateTime other) {
    return startOfWeek.isSameDay(other.startOfWeek);
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  // Age and duration calculations
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  Duration get durationSinceNow => DateTime.now().difference(this);
  Duration get durationUntilNow => difference(DateTime.now());

  // Content-specific utilities
  bool get isNewRelease {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return isAfter(thirtyDaysAgo);
  }

  bool get isRecentlyAdded {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return isAfter(sevenDaysAgo);
  }

  String get releaseStatus {
    final now = DateTime.now();
    if (isAfter(now)) {
      return 'Coming Soon';
    } else if (isNewRelease) {
      return 'New';
    } else {
      return 'Available';
    }
  }

  // Time zone utilities
  DateTime toLocalTimeZone() => toLocal();
  DateTime toUtcTimeZone() => toUtc();

  // Add/subtract utilities
  DateTime addYears(int years) =>
      DateTime(year + years, month, day, hour, minute, second, millisecond);
  DateTime addMonths(int months) {
    int newYear = year;
    int newMonth = month + months;

    while (newMonth > 12) {
      newYear++;
      newMonth -= 12;
    }
    while (newMonth < 1) {
      newYear--;
      newMonth += 12;
    }

    return DateTime(newYear, newMonth, day, hour, minute, second, millisecond);
  }

  DateTime addWeeks(int weeks) => add(Duration(days: weeks * 7));
  DateTime subtractYears(int years) => addYears(-years);
  DateTime subtractMonths(int months) => addMonths(-months);
  DateTime subtractWeeks(int weeks) => addWeeks(-weeks);
}

// Nullable DateTime extensions
extension NullableDateTimeExtension on DateTime? {
  String get timeAgoOrEmpty => this?.timeAgo ?? '';
  String get relativeTimeOrEmpty => this?.relativeTime ?? '';
  bool get isNullOrPast => this == null || this!.isPast;
  bool get isNullOrFuture => this == null || this!.isFuture;
  DateTime get orNow => this ?? DateTime.now();
}
