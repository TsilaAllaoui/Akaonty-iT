import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'dart:async';

class NotificationScheduler {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const int notificationId = 0;

  Future<void> initialize(void Function() run) async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings("akaontyit_logo");
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse res) async {
      run();
    });

    tz.initializeTimeZones();
  }

  Future<void> scheduleMonthlyNotification() async {
    DateTime now = DateTime.now();
    DateTime nextNotificationDate = DateTime(now.year, now.month + 1, 1);

    DateFormat formatter = DateFormat("MMMM dd yyyy");
    String monthName = formatter.format(nextNotificationDate).substring(0, 4);

    var currentDate = tz.TZDateTime.now(tz.local);

    flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      "$monthName is here!",
      "Add new entry for $monthName",
      tz.TZDateTime(tz.local, currentDate.year, currentDate.month + 1, 1),
      const NotificationDetails(
        android: AndroidNotificationDetails('channel_id', 'channel_name',
            channelDescription: 'Akaonty-iT'),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

final notificationScheduler = NotificationScheduler();
