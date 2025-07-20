import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/reminder_model.dart';
import '../core/error_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(initSettings);
      
      // Create notification channel for Android
      await _createNotificationChannel();
    } catch (e) {
      throw AppError(
        message: 'Failed to initialize notifications',
        type: ErrorType.unknown,
        originalError: e,
      );
    }
  }

  Future<void> _createNotificationChannel() async {
    try {
      const androidChannel = AndroidNotificationChannel(
        'reminders_channel',
        'Reminders',
        description: 'Care reminders for clients',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    } catch (e) {
      throw AppError(
        message: 'Failed to create notification channel',
        type: ErrorType.unknown,
        originalError: e,
      );
    }
  }

  Future<bool> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    try {
      print('Scheduling reminder: ${reminder.title} for ${reminder.scheduledTime}');
      
      // Request permissions first
      final granted = await _requestPermissions();
      if (!granted) {
        throw AppError(
          message: 'Notification permission not granted',
          type: ErrorType.permission,
        );
      }
      
      final androidDetails = AndroidNotificationDetails(
        'reminders_channel',
        'Reminders',
        channelDescription: 'Care reminders for clients',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      final scheduledTime = tz.TZDateTime.from(reminder.scheduledTime, tz.local);
      print('Scheduled time: $scheduledTime');
      print('Current time: ${tz.TZDateTime.now(tz.local)}');

      await _notifications.zonedSchedule(
        reminder.id ?? DateTime.now().millisecondsSinceEpoch,
        reminder.title,
        reminder.description,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      print('Reminder scheduled successfully');
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        message: 'Failed to schedule reminder',
        type: ErrorType.unknown,
        originalError: e,
      );
    }
  }

  Future<void> cancelReminder(int reminderId) async {
    await _notifications.cancel(reminderId);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled() ?? false;
      print('System notifications enabled: $enabled');
      return enabled;
    }
    return false;
  }

  Future<void> checkNotificationSettings() async {
    print('=== Checking notification settings ===');
    
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled();
      print('System notifications enabled: $enabled');
      
      final channels = await androidPlugin.getNotificationChannels();
      print('Available channels: ${channels?.length ?? 0}');
      if (channels != null) {
        for (var channel in channels) {
          print('Channel: ${channel.id} - ${channel.name} - Importance: ${channel.importance}');
        }
      }
      
      final pending = await getPendingNotifications();
      print('Pending notifications: ${pending.length}');
    }
  }

  Future<void> showTestNotification() async {
    try {
      print('=== Starting test notification ===');
      
      // Check if notifications are enabled
      final enabled = await areNotificationsEnabled();
      print('Notifications enabled: $enabled');
      if (!enabled) {
        print('Notifications are not enabled');
        return;
      }

      // Request permissions first
      final granted = await _requestPermissions();
      print('Permission granted: $granted');
      if (!granted) {
        print('Notification permission not granted');
        return;
      }

      // Check if channel exists
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final channels = await androidPlugin.getNotificationChannels();
        print('Available channels: ${channels?.length ?? 0}');
        if (channels != null) {
          for (var channel in channels) {
            print('Channel: ${channel.id} - ${channel.name}');
          }
        }
      }

      // Show test notification
      const androidDetails = AndroidNotificationDetails(
        'reminders_channel',
        'Reminders',
        channelDescription: 'Care reminders for clients',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        999999, // Use a unique ID for test notification
        'Test Notification',
        'This is a test notification from Sanyin',
        notificationDetails,
      );
      
      print('Test notification sent successfully');
    } catch (e) {
      print('Error showing test notification: $e');
    }
  }

  void dispose() {
    // Clean up any resources if needed
    // FlutterLocalNotificationsPlugin doesn't require explicit disposal
  }
} 