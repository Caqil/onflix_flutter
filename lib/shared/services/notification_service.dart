import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/constants/storage_keys.dart';
import 'package:onflix/core/network/pocketbase_client.dart';
import 'package:onflix/core/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static NotificationService? _instance;
  late Logger _logger;
  late SharedPreferences _prefs;
  late PocketBaseClient _pbClient;
  late FlutterLocalNotificationsPlugin _localNotifications;

  // Notification management
  final Map<String, NotificationItem> _notifications = {};
  final StreamController<NotificationEvent> _notificationEventController =
      StreamController<NotificationEvent>.broadcast();

  // Settings
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  final Map<String, bool> _notificationTypes = {};

  NotificationService._() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 3,
        lineLength: 80,
        colors: true,
        printEmojis: true,
      ),
    );
    _pbClient = PocketBaseClient.instance;
    _localNotifications = FlutterLocalNotificationsPlugin();
  }

  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  // Stream for notification events
  Stream<NotificationEvent> get notificationEvents =>
      _notificationEventController.stream;

  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Notification Service...');

      _prefs = await SharedPreferences.getInstance();
      await _initializeLocalNotifications();
      await _loadNotificationSettings();
      await _loadNotifications();
      await _scheduleRecurringChecks();

      _logger.i('Notification Service initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Notification Service',
          error: e, stackTrace: stackTrace);
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      _logger.d('Local notifications initialized');
    } catch (e) {
      _logger.e('Failed to initialize local notifications: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      if (Platform.isIOS) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      } else if (Platform.isAndroid) {
        final androidPlugin =
            _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        await androidPlugin?.requestNotificationsPermission();
      }
    } catch (e) {
      _logger.w('Failed to request notification permissions: $e');
    }
  }

  // Load notification settings
  Future<void> _loadNotificationSettings() async {
    _pushNotificationsEnabled =
        _prefs.getBool(StorageKeys.pushNotificationsEnabled) ?? true;
    _emailNotificationsEnabled =
        _prefs.getBool(StorageKeys.emailNotificationsEnabled) ?? true;

    // Load notification type settings
    for (final type in _getNotificationTypes()) {
      final key = '${StorageKeys.notificationSettings}_$type';
      _notificationTypes[type] = _prefs.getBool(key) ?? true;
    }

    _logger.d('Notification settings loaded');
  }

  // Get all notification types
  List<String> _getNotificationTypes() {
    return [
      AppConstants.newContentNotification,
      AppConstants.recommendationNotification,
      AppConstants.downloadCompleteNotification,
      AppConstants.subscriptionNotification,
      AppConstants.systemNotification,
      AppConstants.promotionalNotification,
    ];
  }

  // Load stored notifications
  Future<void> _loadNotifications() async {
    try {
      final notificationsJson = _prefs.getString('stored_notifications');
      if (notificationsJson != null) {
        final Map<String, dynamic> data = jsonDecode(notificationsJson);

        for (final entry in data.entries) {
          final itemData = entry.value as Map<String, dynamic>;
          final notification = NotificationItem.fromJson(itemData);
          _notifications[entry.key] = notification;
        }
      }

      _logger.d('Loaded ${_notifications.length} stored notifications');
    } catch (e) {
      _logger.w('Failed to load stored notifications: $e');
      _notifications.clear();
    }
  }

  // Save notifications to storage
  Future<void> _saveNotifications() async {
    try {
      final data = <String, dynamic>{};
      for (final entry in _notifications.entries) {
        data[entry.key] = entry.value.toJson();
      }

      await _prefs.setString('stored_notifications', jsonEncode(data));
    } catch (e) {
      _logger.e('Failed to save notifications: $e');
    }
  }

  // Schedule recurring notification checks
  Future<void> _scheduleRecurringChecks() async {
    // Check for new notifications every 15 minutes
    Timer.periodic(const Duration(minutes: 15), (timer) async {
      await _checkForNewNotifications();
    });
  }

  // Check for new notifications from server
  Future<void> _checkForNewNotifications() async {
    try {
      if (!_pushNotificationsEnabled) return;

      final response = await _pbClient.getRecords(
        'notifications',
        filter: 'recipient="${_pbClient.currentUser?.id}" && read=false',
        sort: '-created',
      );

      if (response.isSuccess && response.data != null) {
        for (final record in response.data!.items) {
          final notificationId = record.id;

          if (!_notifications.containsKey(notificationId)) {
            final notification = NotificationItem.fromRecord(record);
            await _processNewNotification(notification);
          }
        }
      }
    } catch (e) {
      _logger.w('Failed to check for new notifications: $e');
    }
  }

  // Process new notification
  Future<void> _processNewNotification(NotificationItem notification) async {
    try {
      // Check if notification type is enabled
      if (!(_notificationTypes[notification.type] ?? true)) {
        return;
      }

      // Store notification
      _notifications[notification.id] = notification;
      await _saveNotifications();

      // Show local notification
      await _showLocalNotification(notification);

      // Emit event
      _notificationEventController.add(NotificationEvent(
        type: NotificationEventType.received,
        notification: notification,
      ));

      _logger.d('New notification processed: ${notification.title}');
    } catch (e) {
      _logger.e('Failed to process new notification: $e');
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(NotificationItem notification) async {
    try {
      if (!_pushNotificationsEnabled) return;

      const androidDetails = AndroidNotificationDetails(
        'onflix_channel',
        'Onflix Notifications',
        channelDescription: 'Notifications for Onflix app',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.id.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: jsonEncode(notification.toJson()),
      );

      _logger.d('Local notification shown: ${notification.title}');
    } catch (e) {
      _logger.e('Failed to show local notification: $e');
    }
  }

  // Handle notification tap
  Future<void> _onNotificationTapped(NotificationResponse response) async {
    try {
      if (response.payload != null) {
        final data = jsonDecode(response.payload!);
        final notification = NotificationItem.fromJson(data);

        // Mark as read
        await markAsRead(notification.id);

        // Handle action based on notification type
        await _handleNotificationAction(notification);

        // Emit event
        _notificationEventController.add(NotificationEvent(
          type: NotificationEventType.tapped,
          notification: notification,
        ));
      }
    } catch (e) {
      _logger.e('Failed to handle notification tap: $e');
    }
  }

  // Handle notification action
  Future<void> _handleNotificationAction(NotificationItem notification) async {
    try {
      switch (notification.type) {
        case AppConstants.newContentNotification:
          // Navigate to content details
          if (notification.actionData?['contentId'] != null) {
            _notificationEventController.add(NotificationEvent(
              type: NotificationEventType.actionTriggered,
              notification: notification,
              action: 'navigate_to_content',
              actionData: notification.actionData,
            ));
          }
          break;

        case AppConstants.downloadCompleteNotification:
          // Navigate to downloads
          _notificationEventController.add(NotificationEvent(
            type: NotificationEventType.actionTriggered,
            notification: notification,
            action: 'navigate_to_downloads',
          ));
          break;

        case AppConstants.subscriptionNotification:
          // Navigate to subscription settings
          _notificationEventController.add(NotificationEvent(
            type: NotificationEventType.actionTriggered,
            notification: notification,
            action: 'navigate_to_subscription',
          ));
          break;

        default:
          // Default action - just mark as handled
          break;
      }
    } catch (e) {
      _logger.e('Failed to handle notification action: $e');
    }
  }

  // Send local notification
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    String type = AppConstants.systemNotification,
    Map<String, dynamic>? actionData,
    DateTime? scheduledTime,
  }) async {
    try {
      final notification = NotificationItem(
        id: Helpers.generateId(),
        title: title,
        body: body,
        type: type,
        isRead: false,
        createdAt: DateTime.now(),
        actionData: actionData,
      );

      if (scheduledTime != null) {
        await _scheduleLocalNotification(notification, scheduledTime);
      } else {
        await _showLocalNotification(notification);
      }

      // Store notification
      _notifications[notification.id] = notification;
      await _saveNotifications();

      _logger.d('Local notification sent: $title');
    } catch (e) {
      _logger.e('Failed to send local notification: $e');
    }
  }

  // Schedule local notification
  Future<void> _scheduleLocalNotification(
    NotificationItem notification,
    DateTime scheduledTime,
  ) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'onflix_channel',
        'Onflix Notifications',
        channelDescription: 'Notifications for Onflix app',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        notification.id.hashCode,
        notification.title,
        notification.body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode(notification.toJson()),
      );

      _logger.d('Notification scheduled: ${notification.title}');
    } catch (e) {
      _logger.e('Failed to schedule notification: $e');
    }
  }

  // Send server notification
  Future<void> sendServerNotification({
    required String recipientId,
    required String title,
    required String body,
    String type = AppConstants.systemNotification,
    Map<String, dynamic>? actionData,
  }) async {
    try {
      final data = {
        'recipient': recipientId,
        'title': title,
        'body': body,
        'type': type,
        'action_data': actionData,
        'read': false,
      };

      await _pbClient.createRecord('notifications', data);
      _logger.d('Server notification sent: $title');
    } catch (e) {
      _logger.e('Failed to send server notification: $e');
      rethrow;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final notification = _notifications[notificationId];
      if (notification != null && !notification.isRead) {
        notification.isRead = true;
        notification.readAt = DateTime.now();

        await _saveNotifications();

        // Update on server if it's a server notification
        if (notification.isServerNotification) {
          await _pbClient
              .updateRecord('notifications', notificationId, {'read': true});
        }

        _notificationEventController.add(NotificationEvent(
          type: NotificationEventType.read,
          notification: notification,
        ));

        _logger.d('Notification marked as read: ${notification.title}');
      }
    } catch (e) {
      _logger.e('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final unreadNotifications =
          _notifications.values.where((n) => !n.isRead).toList();

      for (final notification in unreadNotifications) {
        notification.isRead = true;
        notification.readAt = DateTime.now();
      }

      await _saveNotifications();

      // Update server notifications
      for (final notification in unreadNotifications) {
        if (notification.isServerNotification) {
          try {
            await _pbClient
                .updateRecord('notifications', notification.id, {'read': true});
          } catch (e) {
            _logger.w(
                'Failed to update server notification ${notification.id}: $e');
          }
        }
      }

      _notificationEventController.add(NotificationEvent(
        type: NotificationEventType.allRead,
        notification: null,
      ));

      _logger.i('All notifications marked as read');
    } catch (e) {
      _logger.e('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final notification = _notifications.remove(notificationId);
      if (notification != null) {
        await _saveNotifications();

        // Cancel local notification
        await _localNotifications.cancel(notificationId.hashCode);

        // Delete from server if it's a server notification
        if (notification.isServerNotification) {
          await _pbClient.deleteRecord('notifications', notificationId);
        }

        _notificationEventController.add(NotificationEvent(
          type: NotificationEventType.deleted,
          notification: notification,
        ));

        _logger.d('Notification deleted: ${notification.title}');
      }
    } catch (e) {
      _logger.e('Failed to delete notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      _notifications.clear();
      await _saveNotifications();

      // Cancel all local notifications
      await _localNotifications.cancelAll();

      _notificationEventController.add(NotificationEvent(
        type: NotificationEventType.allCleared,
        notification: null,
      ));

      _logger.i('All notifications cleared');
    } catch (e) {
      _logger.e('Failed to clear all notifications: $e');
    }
  }

  // Get all notifications
  List<NotificationItem> getAllNotifications() {
    final notifications = _notifications.values.toList();
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  // Get unread notifications
  List<NotificationItem> getUnreadNotifications() {
    return _notifications.values.where((n) => !n.isRead).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get unread count
  int getUnreadCount() {
    return _notifications.values.where((n) => !n.isRead).length;
  }

  // Update notification settings
  Future<void> updateNotificationSettings({
    bool? pushEnabled,
    bool? emailEnabled,
    Map<String, bool>? typeSettings,
  }) async {
    try {
      if (pushEnabled != null) {
        _pushNotificationsEnabled = pushEnabled;
        await _prefs.setBool(StorageKeys.pushNotificationsEnabled, pushEnabled);
      }

      if (emailEnabled != null) {
        _emailNotificationsEnabled = emailEnabled;
        await _prefs.setBool(
            StorageKeys.emailNotificationsEnabled, emailEnabled);
      }

      if (typeSettings != null) {
        for (final entry in typeSettings.entries) {
          _notificationTypes[entry.key] = entry.value;
          final key = '${StorageKeys.notificationSettings}_${entry.key}';
          await _prefs.setBool(key, entry.value);
        }
      }

      _logger.i('Notification settings updated');
    } catch (e) {
      _logger.e('Failed to update notification settings: $e');
      rethrow;
    }
  }

  // Get notification settings
  Map<String, dynamic> getNotificationSettings() {
    return {
      'pushEnabled': _pushNotificationsEnabled,
      'emailEnabled': _emailNotificationsEnabled,
      'typeSettings': Map<String, bool>.from(_notificationTypes),
    };
  }

  // Send content-specific notifications
  Future<void> sendNewContentNotification({
    required String contentId,
    required String contentTitle,
    required String contentType,
  }) async {
    await sendLocalNotification(
      title: 'New ${contentType.toLowerCase()} available!',
      body: contentTitle,
      type: AppConstants.newContentNotification,
      actionData: {
        'contentId': contentId,
        'contentType': contentType,
      },
    );
  }

  Future<void> sendDownloadCompleteNotification({
    required String contentTitle,
    required String quality,
  }) async {
    await sendLocalNotification(
      title: 'Download Complete',
      body: '$contentTitle ($quality) is ready to watch',
      type: AppConstants.downloadCompleteNotification,
    );
  }

  Future<void> sendRecommendationNotification({
    required String contentTitle,
    required String reason,
  }) async {
    await sendLocalNotification(
      title: 'New Recommendation',
      body: '$contentTitle - $reason',
      type: AppConstants.recommendationNotification,
    );
  }

  Future<void> sendSubscriptionNotification({
    required String message,
    required String action,
  }) async {
    await sendLocalNotification(
      title: 'Subscription Update',
      body: message,
      type: AppConstants.subscriptionNotification,
      actionData: {'action': action},
    );
  }

  // Schedule reminders
  Future<void> scheduleWatchReminder({
    required String contentId,
    required String contentTitle,
    required DateTime reminderTime,
  }) async {
    await sendLocalNotification(
      title: 'Watch Reminder',
      body: "Don't forget to continue watching $contentTitle",
      type: AppConstants.systemNotification,
      actionData: {'contentId': contentId},
      scheduledTime: reminderTime,
    );
  }

  Future<void> scheduleSubscriptionReminder({
    required DateTime expiryDate,
    required String planName,
  }) async {
    final reminderTime = expiryDate.subtract(const Duration(days: 3));

    await sendLocalNotification(
      title: 'Subscription Expiring Soon',
      body: 'Your $planName subscription expires in 3 days',
      type: AppConstants.subscriptionNotification,
      scheduledTime: reminderTime,
    );
  }

  // Get notification statistics
  Map<String, dynamic> getNotificationStats() {
    final notifications = _notifications.values.toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.subtract(Duration(days: today.weekday - 1));
    final thisMonth = DateTime(now.year, now.month);

    final todayNotifications =
        notifications.where((n) => n.createdAt.isAfter(today)).length;

    final weekNotifications =
        notifications.where((n) => n.createdAt.isAfter(thisWeek)).length;

    final monthNotifications =
        notifications.where((n) => n.createdAt.isAfter(thisMonth)).length;

    final typeStats = <String, int>{};
    for (final notification in notifications) {
      typeStats[notification.type] = (typeStats[notification.type] ?? 0) + 1;
    }

    return {
      'total': notifications.length,
      'unread': getUnreadCount(),
      'today': todayNotifications,
      'thisWeek': weekNotifications,
      'thisMonth': monthNotifications,
      'byType': typeStats,
    };
  }

  // Test notification
  Future<void> sendTestNotification() async {
    await sendLocalNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Onflix',
      type: AppConstants.systemNotification,
    );
  }

  // Dispose resources
  void dispose() {
    _notificationEventController.close();
  }
}

// Notification item model
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type;
  bool isRead;
  final DateTime createdAt;
  DateTime? readAt;
  final Map<String, dynamic>? actionData;
  final bool isServerNotification;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.actionData,
    this.isServerNotification = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
        'readAt': readAt?.toIso8601String(),
        'actionData': actionData,
        'isServerNotification': isServerNotification,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        type: json['type'],
        isRead: json['isRead'],
        createdAt: DateTime.parse(json['createdAt']),
        readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
        actionData: json['actionData'],
        isServerNotification: json['isServerNotification'] ?? false,
      );

  factory NotificationItem.fromRecord(dynamic record) => NotificationItem(
        id: record.id,
        title: record.data['title'],
        body: record.data['body'],
        type: record.data['type'],
        isRead: record.data['read'] ?? false,
        createdAt: DateTime.parse(record.data['created']),
        actionData: record.data['action_data'],
        isServerNotification: true,
      );
}

// Notification event model
class NotificationEvent {
  final NotificationEventType type;
  final NotificationItem? notification;
  final String? action;
  final Map<String, dynamic>? actionData;

  NotificationEvent({
    required this.type,
    this.notification,
    this.action,
    this.actionData,
  });
}

// Notification event types
enum NotificationEventType {
  received,
  read,
  allRead,
  deleted,
  allCleared,
  tapped,
  actionTriggered,
}
