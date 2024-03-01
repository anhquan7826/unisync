import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

class RingPhonePlugin extends UnisyncPlugin {
  RingPhonePlugin(super.emitter);

  @override
  bool isPluginMessage(DeviceMessage message) {
    return message.type == DeviceMessage.Type.RING_PHONE;
  }

  @override
  void onMessageReceived(DeviceMessage message) {}

  void ringMyPhone() {
    emitter.sendMessage(DeviceMessage(
      type: DeviceMessage.Type.RING_PHONE,
      body: {},
    ));
  }
}
