import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotification {
  PushNotification._();

  static final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> setup() async {
    const initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Open notification');
    const initializationSettings = InitializationSettings(linux: initializationSettingsLinux);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification({required String title, required String text}) async {
    const notification = LinuxNotificationDetails(
      category: LinuxNotificationCategory.im,
      resident: true,
    );
    const details = NotificationDetails(
      linux: notification,
    );
    await _flutterLocalNotificationsPlugin.show(0, title, text, details);
  }
}
