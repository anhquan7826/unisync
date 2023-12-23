import 'package:unisync/models/device_info/device_info.model.dart';

abstract class ConnectionRepository {
  Future<List<DeviceInfo>> getAvailableDevices();

  void addDeviceChangeListener({
    required void Function(DeviceInfo) onDeviceAdd,
    required void Function(DeviceInfo) onDeviceRemove,
  });

  void removeDeviceChangeListener();

  Future<void> connectToAddress(String ipAddress);
}
