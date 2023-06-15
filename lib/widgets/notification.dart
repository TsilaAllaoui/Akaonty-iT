import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';

class NotificationScheduler {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const int notificationId = 0;
  Timer? _timer;

  Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleMonthlyNotification() async {
    await AndroidAlarmManager.cancel(notificationId);

    DateTime now = DateTime.now();
    DateTime nextNotificationDate = DateTime(now.year, now.month + 1, 1);

    await AndroidAlarmManager.periodic(
      const Duration(days: 30),
      notificationId,
      showMonthlyNotification,
      startAt: nextNotificationDate,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  Future<void> showMonthlyNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      'Monthly Reminder',
      'This is your reminder for the new month!',
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }

  Future<void> cancelNotifications() async {
    await AndroidAlarmManager.cancel(notificationId);
  }
}
