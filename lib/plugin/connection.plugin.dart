import 'dart:async';

import 'package:unisync/core/device_entry_point.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/plugin/base_plugin.dart';

class ConnectionPlugin extends UnisyncPlugin {
  factory ConnectionPlugin() {
    _i ??= ConnectionPlugin();
    return _i!;
  }

  static ConnectionPlugin? _i;

  StreamSubscription<DeviceInfo>? _deviceAddSubscription;
  StreamSubscription<DeviceInfo>? _deviceRemoveSubscription;

  @override
  String plugin = UnisyncPlugin.PLUGIN_CONNECTION;

  @override
  Future<void> stop() async {}

  void subscribeDeviceChanges(void Function(DeviceInfo) onAdd, void Function(DeviceInfo) onRemove) {
    _deviceAddSubscription = DeviceEntryPoint.notifiers.connectedDeviceNotifier.listen(onAdd);
    _deviceRemoveSubscription = DeviceEntryPoint.notifiers.disconnectedDeviceNotifier.listen(onRemove);
  }

  void unsubscribeDeviceChanges() {
    _deviceAddSubscription?.cancel();
    _deviceAddSubscription = null;
    _deviceRemoveSubscription?.cancel();
    _deviceRemoveSubscription = null;
  }

  List<DeviceInfo> getAllConnected() {
    return DeviceEntryPoint.devices;
  }
}
