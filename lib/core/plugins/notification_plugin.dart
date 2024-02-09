import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/push_notification.dart';

class NotificationPlugin extends UnisyncPlugin {
  NotificationPlugin(super.emitter);

  @override
  bool isPluginMessage(DeviceMessage message) {
    return message.type == DeviceMessage.Type.NOTIFICATION;
  }

  @override
  void onMessageReceived(DeviceMessage message) {
    PushNotification.showNotification(
      title: message.body['title'].toString(),
      text: message.body['text'].toString(),
    );
  }
}
