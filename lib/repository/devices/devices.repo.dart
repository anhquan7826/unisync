import 'package:unisync_backend/models/device_info/device_info.model.dart';

abstract interface class DevicesRepository {
  Future<List<DeviceInfo>> getConnectedDevices();

  void connectToDevice(String ip);

  void registerConnectionListener(DevicesRepositoryConnectionListener listener);

  void unregisterConnectionListener(DevicesRepositoryConnectionListener listener);
}

abstract interface class DevicesRepositoryConnectionListener {
  void onConnected(DeviceInfo device);

  void onDisconnected(DeviceInfo device);
}
