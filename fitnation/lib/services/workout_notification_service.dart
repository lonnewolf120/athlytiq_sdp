import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';

class WorkoutNotificationService {
  static final WorkoutNotificationService _instance =
      WorkoutNotificationService._internal();
  factory WorkoutNotificationService() => _instance;
  WorkoutNotificationService._internal();

  /// Initialize notification permissions
  Future<bool> initializeNotifications() async {
    try {
      // Request permission for notifications
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        isAllowed =
            await AwesomeNotifications().requestPermissionToSendNotifications();
      }

      if (isAllowed) {
        // Set up notification action listeners
        await _setupNotificationListeners();
      }

      return isAllowed;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      return false;
    }
  }

  /// Set up notification listeners for handling notification taps
  Future<void> _setupNotificationListeners() async {
    // Listen for notification action (when user taps notification)
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
    );
  }

  /// Handle notification actions (when user taps notification)
  @pragma("vm:entry-point")
  static Future<void> _onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('Notification action received: ${receivedAction.actionType}');

    // Handle different notification actions
    switch (receivedAction.payload?['action']) {
      case 'start_workout':
        // TODO: Navigate to workout start screen
        debugPrint(
          'User wants to start workout: ${receivedAction.payload?['workout_id']}',
        );
        break;
      case 'view_workout':
        // TODO: Navigate to workout detail screen
        debugPrint(
          'User wants to view workout: ${receivedAction.payload?['workout_id']}',
        );
        break;
      default:
        debugPrint('Default notification action');
    }
  }

  /// Handle when notification is created
  @pragma("vm:entry-point")
  static Future<void> _onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('Notification created: ${receivedNotification.id}');
  }

  /// Handle when notification is displayed
  @pragma("vm:entry-point")
  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('Notification displayed: ${receivedNotification.id}');
  }

  /// Schedule a workout reminder notification
  Future<bool> scheduleWorkoutReminder({
    required String workoutId,
    required String workoutName,
    required DateTime scheduledTime,
    String? workoutType,
    int reminderMinutesBefore = 30,
  }) async {
    try {
      final notificationTime = scheduledTime.subtract(
        Duration(minutes: reminderMinutesBefore),
      );

      // Don't schedule notifications for past dates
      if (notificationTime.isBefore(DateTime.now())) {
        debugPrint('Cannot schedule notification for past time');
        return false;
      }

      final notificationId = _generateNotificationId(
        workoutId,
        reminderMinutesBefore,
      );

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'workout_reminders',
          title: '🏋️ Workout Reminder',
          body:
              'Your "$workoutName" workout is starting in $reminderMinutesBefore minutes!',
          bigPicture: null,
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
          payload: {
            'workout_id': workoutId,
            'workout_name': workoutName,
            'workout_type': workoutType ?? '',
            'action': 'start_workout',
          },
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'start_workout',
            label: 'Start Workout',
            actionType: ActionType.Default,
          ),
          NotificationActionButton(
            key: 'view_details',
            label: 'View Details',
            actionType: ActionType.Default,
          ),
        ],
        schedule: NotificationCalendar.fromDate(
          date: notificationTime,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );

      debugPrint(
        'Scheduled workout reminder for $workoutName at $notificationTime (ID: $notificationId)',
      );
      return true;
    } catch (e) {
      debugPrint('Error scheduling workout reminder: $e');
      return false;
    }
  }

  /// Schedule multiple reminders for a workout
  Future<List<bool>> scheduleMultipleReminders({
    required String workoutId,
    required String workoutName,
    required DateTime scheduledTime,
    String? workoutType,
    List<int> reminderMinutes = const [
      60,
      30,
      10,
    ], // 1 hour, 30 min, 10 min before
  }) async {
    final results = <bool>[];

    for (final minutes in reminderMinutes) {
      final success = await scheduleWorkoutReminder(
        workoutId: workoutId,
        workoutName: workoutName,
        scheduledTime: scheduledTime,
        workoutType: workoutType,
        reminderMinutesBefore: minutes,
      );
      results.add(success);
    }

    return results;
  }

  /// Send an immediate motivational notification
  Future<bool> sendMotivationalNotification({
    required String title,
    required String message,
    String? workoutId,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          channelKey: 'workout_motivation',
          title: title,
          body: message,
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: false,
          category: NotificationCategory.Reminder,
          payload: {'workout_id': workoutId ?? '', 'action': 'motivation'},
        ),
      );

      return true;
    } catch (e) {
      debugPrint('Error sending motivational notification: $e');
      return false;
    }
  }

  /// Cancel a specific workout reminder
  Future<bool> cancelWorkoutReminder({
    required String workoutId,
    int reminderMinutesBefore = 30,
  }) async {
    try {
      final notificationId = _generateNotificationId(
        workoutId,
        reminderMinutesBefore,
      );
      await AwesomeNotifications().cancel(notificationId);
      debugPrint('Cancelled workout reminder (ID: $notificationId)');
      return true;
    } catch (e) {
      debugPrint('Error cancelling workout reminder: $e');
      return false;
    }
  }

  /// Cancel all reminders for a specific workout
  Future<bool> cancelAllWorkoutReminders(String workoutId) async {
    try {
      // Cancel common reminder intervals
      final reminderIntervals = [60, 30, 10, 5];
      for (final minutes in reminderIntervals) {
        await cancelWorkoutReminder(
          workoutId: workoutId,
          reminderMinutesBefore: minutes,
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error cancelling all workout reminders: $e');
      return false;
    }
  }

  /// Get all scheduled notifications
  Future<List<NotificationModel>> getScheduledNotifications() async {
    try {
      return await AwesomeNotifications().listScheduledNotifications();
    } catch (e) {
      debugPrint('Error getting scheduled notifications: $e');
      return [];
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  /// Request notification permissions
  Future<bool> requestNotificationPermissions() async {
    return await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  /// Generate a unique notification ID for a workout reminder
  int _generateNotificationId(String workoutId, int reminderMinutes) {
    // Create a hash-like ID using workout ID and reminder time
    final combined = '$workoutId-$reminderMinutes';
    return combined.hashCode.abs() % 2147483647; // Keep within int32 range
  }

  /// Send daily workout reminder (can be called from a background task)
  Future<bool> sendDailyMotivation() async {
    final motivationalMessages = [
      "💪 Ready to crush today's workout?",
      "🔥 Your fitness journey continues today!",
      "⚡ Time to get stronger than yesterday!",
      "🏆 Every workout counts - let's do this!",
      "💯 Consistency is key - start your workout!",
      "🚀 Push your limits and achieve greatness!",
      "💪 Your body can do it. It's your mind you have to convince!",
      "🔥 The only bad workout is the one that didn't happen!",
    ];

    final randomIndex =
        DateTime.now().millisecond % motivationalMessages.length;
    final message = motivationalMessages[randomIndex];

    return await sendMotivationalNotification(
      title: "Daily Motivation",
      message: message,
    );
  }
}
