import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/push_notification.dart';

import '../device.dart';

class NotificationPlugin extends UnisyncPlugin {
  NotificationPlugin(Device device) : super(device, type: DeviceMessage.Type.NOTIFICATION);

  @override
  void onReceive(Map<String, dynamic> data) {
    PushNotification.showNotification(
      title: data['title'].toString(),
      text: data['text'].toString(),
    );
  }
}
