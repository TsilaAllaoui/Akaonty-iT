import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:expense/widgets/home.dart';
import 'package:expense/widgets/notification_service.dart';

void run() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.grey,
          fontFamily: "Ubuntu",
        ),
        home: const Home(),
      ),
    ),
  );
}

Future<void> initializeNotificationScheduler(run) async {
  await notificationScheduler.initialize(run);
}

Future<void> scheduleMonthlyNotification() async {
  await notificationScheduler.scheduleMonthlyNotification();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeNotificationScheduler(run);
  await scheduleMonthlyNotification();

  run();
}
