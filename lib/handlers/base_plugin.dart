// ignore_for_file: constant_identifier_names

import 'package:unisync/core/device_entry_point.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

abstract class UnisyncPlugin {
  static const PLUGIN_CONNECTION = 'connection';
  static const PLUGIN_PAIRING = 'pairing';

  abstract final String plugin;
  var enabled = true;

  Future<void> start() async {
    DeviceEntryPoint.notifiers
      ..connectedDeviceNotifier.listen(enabled ? onDeviceConnected : (_) {})
      ..disconnectedDeviceNotifier.listen(enabled ? onDeviceDisconnected : (_) {})
      ..deviceMessageNotifier.listen(enabled ? onDeviceMessage : (_) {});
  }

  Future<void> stop() async {}

  void send({
    required String deviceId,
    required String function,
    Map<String, dynamic> extra = const {},
  }) {
    DeviceEntryPoint.send(
      toDeviceId: deviceId,
      plugin: plugin,
      function: function,
      extra: extra,
    );
  }

  void onDeviceConnected(DeviceInfo info) {}

  void onDeviceDisconnected(DeviceInfo info) {}

  void onDeviceMessage(DeviceMessage message) {}
}

abstract class UnisyncPluginSignal {}
