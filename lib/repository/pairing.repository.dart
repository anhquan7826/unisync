import 'package:unisync/models/device_info/device_info.model.dart';

abstract class PairingRepository {
  /// Get paired devices, include connected and disconnected devices.
  Future<List<DeviceInfo>> getPairedDevices();

  Future<void> sendPairRequestTo(String deviceId);

  Future<void> acceptPairRequestFrom(String deviceId);

  Future<void> rejectPairRequestFrom(String deviceId);

  void addDevicePairListener(void Function(DeviceInfo) onPairRequest);

  void removeDevicePairListener();
}
