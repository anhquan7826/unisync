import 'package:unisync/core/device.dart';
import 'package:unisync/core/device_connection.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/models/notification_data/notification_data.model.dart';
import 'package:unisync/utils/logger.dart';
import 'package:unisync/utils/payload_handler.dart';
import 'package:unisync/utils/push_notification.dart';

class NotificationPlugin extends UnisyncPlugin {
  NotificationPlugin(Device device)
      : super(device, type: DeviceMessage.Type.NOTIFICATION);

  final List<NotificationData> _notifications = [];

  List<NotificationData> get notifications => _notifications.toList();

  @override
  void onReceive(Map<String, dynamic> data, Payload? payload) {
    super.onReceive(data, payload);
    var notification = NotificationData(
        timestamp: data['timestamp'],
        appName: data['app_name'].toString(),
        title: data['title'].toString(),
        text: data['text'].toString(),
        subText: data['sub_text']?.toString(),
        bigText: data['big_text']?.toString());
    if (payload != null) {
      getPayloadData(
        payload.stream,
        size: payload.size,
      ).then(
        (value) {
          notification = notification.copyWith(
            icon: value,
          );
          _displayNotification(notification);
        },
        onError: (e) {
          errorLog(e);
          _displayNotification(notification);
        },
      );
    } else {
      _displayNotification(notification);
    }
  }

  void _displayNotification(NotificationData notification) {
    PushNotification.showNotification(
      title: '${notification.appName} • ${notification.title}',
      text:
          '${notification.text}${notification.subText != null ? '\n${notification.subText}' : ''}${notification.bigText != null ? '\n${notification.bigText}' : ''}',
    );
    _addNotification(notification);
  }

  void _addNotification(NotificationData notification) {
    _notifications.add(notification);
    notifier.add({'notifications': notifications});
  }

  void clearNotification([NotificationData? notification]) {
    if (notification != null) {
      _notifications.remove(notification);
    } else {
      _notifications.clear();
    }
    notifier.add({'notifications': notifications});
  }
}
