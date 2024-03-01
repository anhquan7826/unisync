import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

class BatteryPlugin extends UnisyncPlugin {
  BatteryPlugin(super.emitter);

  @override
  bool isPluginMessage(DeviceMessage message) {
    return message.type == DeviceMessage.Type.BATTERY;
  }

  @override
  void onMessageReceived(DeviceMessage message) {
    notifier.add(message.body);
  }

  void getBatteryInfo() {
    emitter.sendMessage(DeviceMessage(
      type: DeviceMessage.Type.BATTERY,
      body: {'request': 'get_info'},
    ));
  }
}
