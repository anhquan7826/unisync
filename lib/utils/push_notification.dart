import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:unisync/components/resources/resources.dart';
import 'package:unisync/utils/debouncer.dart';

class PushNotification {
  PushNotification._();

  static final _debouncer = Debouncer(const Duration(seconds: 1));

  static final _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> setup() async {
    const initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    const initializationSettings =
        InitializationSettings(linux: initializationSettingsLinux);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification({
    Uint8List? icon,
    required String title,
    required String text,
  }) async {
    _debouncer.call(() async {
      final notification = LinuxNotificationDetails(
        icon: ByteDataLinuxIcon(
          LinuxRawIconData(
            data: icon ?? await _getDefaultIcon(),
            width: 256,
            height: 256,
          ),
        ),
        category: LinuxNotificationCategory.transferComplete,
        resident: true,
      );
      final details = NotificationDetails(
        linux: notification,
      );
      await _flutterLocalNotificationsPlugin.show(
        0,
        title,
        text,
        details,
      );
    });
  }

  static Uint8List? _defaultIcon;
  static Future<Uint8List> _getDefaultIcon() async {
    _defaultIcon ??=
        (await rootBundle.load(R.images.app_icon)).buffer.asUint8List();
    return _defaultIcon!;
  }
}
