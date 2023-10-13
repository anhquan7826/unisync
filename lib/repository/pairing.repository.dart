import 'package:unisync/models/device_info/device_info.model.dart';

abstract class PairingRepository {
  Future<List<DeviceInfo>?> getDiscoveredDevices();

  void deviceDiscoveryListener(void Function(DeviceInfo) onClientAdded, void Function(DeviceInfo) onClientRemoved);

  void pairRequestListener(void Function(DeviceInfo) incomingDevice);

  Future<void> acceptPair(DeviceInfo device);

  Future<bool> requestPair(DeviceInfo device);
}
