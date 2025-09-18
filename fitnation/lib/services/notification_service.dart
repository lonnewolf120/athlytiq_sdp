import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static ReceivePort? receivePort;

  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: false,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel_group',
          channelGroupName: 'Group 1',
        ),
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then((
      isAllowed,
    ) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications(
          channelKey: 'high_importance_channel',
        );
      }
    });

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  /// Use this method to detect when a new notification or a schedule is created
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('onNotificationCreatedMethod');
  }

  /// Use this method to detect every time that a new notification is displayed
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  /// Use this method to detect if the user dismissed a notification
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      debugPrint('Silent action received: "${receivedAction.buttonKeyInput}"');
    } else {
      if (receivePort == null) {
        debugPrint(
          'onActionReceivedMethod was called inside a parallel dart isolate.',
        );
        SendPort? sendPort = IsolateNameServer.lookupPortByName(
          'notification_action_port',
        );

        if (sendPort != null) {
          sendPort.send(receivedAction);
          return;
        }
      }
      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  static Future<void> onActionReceivedImplementationMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint("Action received: ${receivedAction.buttonKeyPressed}");
    // Handle notification actions here
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
  }) async {
    assert(!scheduled || (scheduled && interval != null));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'high_importance_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
      ),
      actionButtons: actionButtons,
      schedule:
          scheduled
              ? NotificationInterval(
                interval:
                    interval != null
                        ? Duration(seconds: interval)
                        : Duration.zero,
                timeZone:
                    await AwesomeNotifications().getLocalTimeZoneIdentifier(),
                preciseAlarm: true,
              )
              : null,
    );
  }

  static Future<Widget> checkNotificationPermission(
    BuildContext context,
  ) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Show dialog to ask for permission
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Allow Notifications'),
              content: const Text(
                'To receive important updates, please enable notifications for this app.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    debugPrint("Notifications disabled by user");
                  },
                  child: const Text('Don\'t Allow'),
                ),
                TextButton(
                  onPressed: () async {
                    await NotificationService.initializeNotification();
                    Navigator.of(context).pop();
                    debugPrint("Notifications enabled by user");
                  },
                  child: const Text('Allow'),
                ),
              ],
            ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> createScheduleNotification(
    DateTime scheduledTime,
    String title,
    String body,
    String? bigPictureUrl,
  ) async {
    try {
      await AwesomeNotifications().createNotification(
        schedule: NotificationCalendar(
          day: scheduledTime.day,
          month: scheduledTime.month,
          year: scheduledTime.year,
          hour: scheduledTime.hour,
          minute: scheduledTime.minute,
        ),
        content: NotificationContent(
          id: -1,
          channelKey: 'high_importance_channel',
          title: title,
          body: body,
          bigPicture: bigPictureUrl,
          notificationLayout:
              bigPictureUrl != null
                  ? NotificationLayout.BigPicture
                  : NotificationLayout.Default,
        ),
      );
    } catch (e) {
      debugPrint('Error creating scheduled notification: $e');
    }
  }
}
