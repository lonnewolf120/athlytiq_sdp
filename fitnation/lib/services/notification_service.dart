import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _isInitialized = true;
    debugPrint('NotificationService: Initialized successfully');
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint(
      'NotificationService: Notification tapped with payload: ${response.payload}',
    );
    // Handle notification tap here
    // You can navigate to specific screens based on the payload
  }

  Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      final bool? granted =
          await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    if (iosImplementation != null) {
      final bool? granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  Future<void> scheduleMealReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminders',
          'Meal Reminders',
          channelDescription: 'Reminders for meal times and nutrition goals',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          sound: RawResourceAndroidNotificationSound('notification_sound'),
        ),
        iOS: DarwinNotificationDetails(
          sound: 'notification_sound.aiff',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    debugPrint(
      'NotificationService: Scheduled meal reminder for ${scheduledTime.toIso8601String()}',
    );
  }

  Future<void> scheduleRepeatingMealReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_meal_reminders',
          'Daily Meal Reminders',
          channelDescription: 'Daily reminders for meal times',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time, // This makes it repeat daily
      payload: payload,
    );

    debugPrint(
      'NotificationService: Scheduled repeating meal reminder for ${time.formatTime()}',
    );
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'immediate_notifications',
          'Immediate Notifications',
          channelDescription: 'Immediate notifications for app events',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );

    debugPrint('NotificationService: Showed immediate notification: $title');
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    debugPrint('NotificationService: Cancelled notification with ID: $id');
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('NotificationService: Cancelled all notifications');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Predefined meal reminder schedules
  Future<void> scheduleDailyMealReminders({
    required String userName,
    TimeOfDay? breakfastTime,
    TimeOfDay? lunchTime,
    TimeOfDay? dinnerTime,
    TimeOfDay? snackTime,
  }) async {
    // Cancel existing meal reminders
    await cancelMealReminders();

    if (breakfastTime != null) {
      await scheduleRepeatingMealReminder(
        id: 1001,
        title: 'Good Morning, $userName! 🌅',
        body: 'Time for a healthy breakfast to fuel your day!',
        time: breakfastTime,
        payload: 'breakfast_reminder',
      );
    }

    if (lunchTime != null) {
      await scheduleRepeatingMealReminder(
        id: 1002,
        title: 'Lunch Time, $userName! 🥗',
        body: 'Keep your energy up with a nutritious lunch!',
        time: lunchTime,
        payload: 'lunch_reminder',
      );
    }

    if (dinnerTime != null) {
      await scheduleRepeatingMealReminder(
        id: 1003,
        title: 'Dinner Time, $userName! 🍽️',
        body: 'End your day with a satisfying dinner!',
        time: dinnerTime,
        payload: 'dinner_reminder',
      );
    }

    if (snackTime != null) {
      await scheduleRepeatingMealReminder(
        id: 1004,
        title: 'Snack Time, $userName! 🍎',
        body: 'Time for a healthy snack to keep you going!',
        time: snackTime,
        payload: 'snack_reminder',
      );
    }
  }

  Future<void> cancelMealReminders() async {
    const mealReminderIds = [1001, 1002, 1003, 1004];
    for (final id in mealReminderIds) {
      await cancelNotification(id);
    }
  }

  Future<void> scheduleCalorieGoalReminder({
    required String userName,
    required int currentCalories,
    required int targetCalories,
  }) async {
    final remaining = targetCalories - currentCalories;
    if (remaining <= 0) return;

    // Schedule reminder for 2 hours later
    final reminderTime = DateTime.now().add(const Duration(hours: 2));

    await scheduleMealReminder(
      id: 2001,
      title: 'Calorie Goal Check 📊',
      body:
          'Hi $userName! You need $remaining more calories to reach your daily goal.',
      scheduledTime: reminderTime,
      payload: 'calorie_goal_reminder',
    );
  }

  Future<void> scheduleHydrationReminder({required String userName}) async {
    // Schedule hydration reminders every 2 hours during the day
    final now = DateTime.now();
    final reminderTimes = [
      DateTime(now.year, now.month, now.day, 9, 0), // 9 AM
      DateTime(now.year, now.month, now.day, 11, 0), // 11 AM
      DateTime(now.year, now.month, now.day, 13, 0), // 1 PM
      DateTime(now.year, now.month, now.day, 15, 0), // 3 PM
      DateTime(now.year, now.month, now.day, 17, 0), // 5 PM
      DateTime(now.year, now.month, now.day, 19, 0), // 7 PM
    ];

    for (int i = 0; i < reminderTimes.length; i++) {
      final reminderTime = reminderTimes[i];
      if (reminderTime.isAfter(now)) {
        await scheduleMealReminder(
          id: 3000 + i,
          title: 'Stay Hydrated! 💧',
          body: 'Hi $userName! Remember to drink water throughout the day.',
          scheduledTime: reminderTime,
          payload: 'hydration_reminder',
        );
      }
    }
  }
}

extension TimeOfDayFormat on TimeOfDay {
  String formatTime() {
    final hours = hour.toString().padLeft(2, '0');
    final minutes = minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
