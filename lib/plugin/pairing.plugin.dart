import 'package:unisync/core/device_entry_point.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/plugin/base_plugin.dart';
import 'package:unisync/utils/configs.dart';

class PairingPlugin extends UnisyncPlugin {
  @override
  String get plugin => UnisyncPlugin.PLUGIN_PAIRING;

  final _requestPairStack = <DeviceInfo>[];

  void Function(DeviceInfo)? onPairRequestFrom;
  void Function(DeviceInfo)? onAcceptFrom;
  void Function(DeviceInfo)? onRejectFrom;

  void subscribePairState({
    required void Function(DeviceInfo) onPairRequestFrom,
    required void Function(DeviceInfo) onAcceptFrom,
    required void Function(DeviceInfo) onRejectFrom,
  }) {
    this.onPairRequestFrom = onPairRequestFrom;
    this.onAcceptFrom = onAcceptFrom;
    this.onRejectFrom = onRejectFrom;
  }

  void unsubscribePairState() {
    onPairRequestFrom = null;
    onAcceptFrom = null;
    onRejectFrom = null;
  }

  @override
  void onDeviceMessage(DeviceMessage message) {
    if (message.plugin == plugin) {
      if (message.function == DeviceMessage.Pairing.REQUEST_PAIR) {
        _onIncomingPairRequest(message.fromDeviceId);
      }
      if (message.function == DeviceMessage.Pairing.PAIR_ACCEPTED) {
        _onPairRequestAccepted(message.fromDeviceId);
      }
      if (message.function == DeviceMessage.Pairing.PAIR_REJECTED) {
        _onPairRequestRejected(message.fromDeviceId);
      }
    }
  }

  void _onIncomingPairRequest(String fromDeviceId) {
    final deviceInfo = DeviceEntryPoint.devices.firstWhere((element) => element.id == fromDeviceId);
    _requestPairStack
      ..removeWhere((element) => element.id == fromDeviceId)
      ..insert(0, deviceInfo);
    onPairRequestFrom?.call(deviceInfo);
  }

  void _onPairRequestAccepted(String fromDeviceId) {
    final device = DeviceEntryPoint.devices.firstWhere((element) => element.id == fromDeviceId);
    ConfigUtil.device.addPairedDevice(device);
    onAcceptFrom?.call(device);
  }

  void _onPairRequestRejected(String fromDeviceId) {
    final device = DeviceEntryPoint.devices.firstWhere((element) => element.id == fromDeviceId);
    onRejectFrom?.call(device);
  }
}
