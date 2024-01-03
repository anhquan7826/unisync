import 'package:unisync/repository/pairing.repository.dart';
import 'package:unisync_backend/models/device_info/device_info.model.dart';

class PairingRepositoryImpl extends PairingRepository {
  void Function(DeviceInfo p1)? onPairRequestListener;

  @override
  Future<void> acceptPairRequestFrom(String deviceId) {
    // TODO: implement acceptPairRequestFrom
    throw UnimplementedError();
  }

  @override
  Future<List<DeviceInfo>> getPairedDevices() {
    // TODO: implement getPairedDevices
    throw UnimplementedError();
  }

  @override
  Future<void> rejectPairRequestFrom(String deviceId) {
    // TODO: implement rejectPairRequestFrom
    throw UnimplementedError();
  }

  @override
  Future<void> sendPairRequestTo(String deviceId) {
    // TODO: implement sendPairRequestTo
    throw UnimplementedError();
  }

  @override
  void addDevicePairListener(void Function(DeviceInfo p1) onPairRequest) {
    onPairRequestListener = onPairRequest;
  }

  @override
  void removeDevicePairListener() {
    onPairRequestListener = null;
  }
}
