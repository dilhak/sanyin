import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/reminder_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
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
  }

  Future<void> _createNotificationChannel() async {
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
        print('Notification permission not granted');
        return;
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
      print('Error scheduling reminder: $e');
      rethrow;
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
      print('Available channels: ${channels.length}');
      for (var channel in channels) {
        print('Channel: ${channel.id} - ${channel.name} - Importance: ${channel.importance}');
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
        print('Available channels: ${channels.length}');
        for (var channel in channels) {
          print('Channel: ${channel.id} - ${channel.name}');
        }
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
        showWhen: true,
        enableShowBadge: true,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      print('Showing notification...');
      await _notifications.show(
        999,
        'Test Reminder',
        'This is a test notification',
        notificationDetails,
      );
      
      print('Test notification shown successfully');
      
      // Check pending notifications
      final pending = await getPendingNotifications();
      print('Pending notifications: ${pending.length}');
      
    } catch (e) {
      print('Error showing test notification: $e');
      print('Error stack trace: ${e.toString()}');
      rethrow;
    }
  }
} 