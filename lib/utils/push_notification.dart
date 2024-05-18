import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image/image.dart';
import 'package:unisync/components/resources/resources.dart';
import 'package:unisync/utils/debouncer.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';
import 'package:unisync/utils/logger.dart';

class PushNotification {
  PushNotification._();

  static final _debouncer = Debouncer(const Duration(seconds: 1));

  static final _flutterLocalNotificationsPlugin =
      LinuxFlutterLocalNotificationsPlugin();

  static Future<void> setup() async {
    final initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon(R.images.app_icon),
    );
    await _flutterLocalNotificationsPlugin
        .initialize(initializationSettingsLinux);
  }

  static Future<void> showNotification({
    Uint8List? icon,
    required String title,
    required String text,
  }) async {
    _debouncer.call(() async {
      final details = LinuxNotificationDetails(
        icon: getIcon(icon),
      );
      debugLog('Showing notification...');
      await _flutterLocalNotificationsPlugin.show(
        0,
        title,
        text,
        notificationDetails: details,
      );
    });
  }

  static ByteDataLinuxIcon? getIcon(Uint8List? icon) {
    return icon?.let((it) {
      final iconData = decodeImage(it);
      if (iconData == null) {
        return null;
      }
      return ByteDataLinuxIcon(
        LinuxRawIconData(
          data: iconData.getBytes(),
          width: iconData.width,
          height: iconData.height,
          channels: 4,
          hasAlpha: true,
        ),
      );
    });
  }
}
