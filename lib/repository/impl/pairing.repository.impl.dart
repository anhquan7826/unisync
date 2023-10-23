import 'dart:convert';
import 'dart:io';

import 'package:unisync/backend/device_connection/device_connection.dart';
import 'package:unisync/constants/channel_result_code.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/repository/pairing.repository.dart';
import 'package:unisync/utils/channels.dart';

class PairingRepositoryImpl extends PairingRepository {
  @override
  Future<void> acceptPair(DeviceInfo device) async {}

  @override
  void deviceDiscoveryListener(void Function(DeviceInfo device) onClientAdded, void Function(DeviceInfo device) onClientRemoved) {}

  @override
  void pairRequestListener(void Function(DeviceInfo p1) incomingDevice) {
    // TODO: implement pairRequestListener
  }

  @override
  Future<bool> requestPair(DeviceInfo device) async {
    // TODO: implement requestPair
    return true;
  }

  @override
  Future<List<DeviceInfo>?> getDiscoveredDevices() async {
    if (Platform.isAndroid) {
      final result = await UnisyncChannels.connection.invokeMethod(ConnectionChannel.nativeGetDiscoveredDevices);
      if (result.resultCode == ChannelResultCode.success) {
        return (result.result as List).map((e) {
          return DeviceInfo.fromJson((e as Map).cast<String, dynamic>());
        }).toList();
      } else {
        return null;
      }
    } else {
      return DeviceConnection.getUnpairedDevice();
    }
  }

  @override
  void clearListener() {}
}
