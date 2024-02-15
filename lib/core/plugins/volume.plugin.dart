import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';

class VolumePlugin extends UnisyncPlugin {
  VolumePlugin(super.emitter);

  @override
  bool isPluginMessage(DeviceMessage message) {
    return message.type == DeviceMessage.Type.VOLUME;
  }

  @override
  void onMessageReceived(DeviceMessage message) {
    _setVolume(message.body['value']);
  }

  Future<void> _setVolume(double value) async {
    await FlutterVolumeController.setVolume(value);
  }
}
