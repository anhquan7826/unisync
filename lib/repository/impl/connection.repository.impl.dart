import 'dart:io';

import 'package:unisync/core/device_entry_point.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/plugin/connection.plugin.dart';
import 'package:unisync/repository/connection.repository.dart';
import 'package:unisync/utils/channels.dart';
import 'package:unisync/utils/extensions/string.ext.dart';

class ConnectionRepositoryImpl extends ConnectionRepository {
  @override
  void addDeviceChangeListener({
    required void Function(DeviceInfo) onDeviceAdd,
    required void Function(DeviceInfo) onDeviceRemove,
  }) {
    if (Platform.isAndroid) {
      UnisyncChannels.connection
        ..addCallHandler(
          ConnectionChannel.ON_DEVICE_CONNECTED,
          (arguments) {
            final device = DeviceInfo.fromJson(arguments!['device']);
            onDeviceAdd(device);
          },
        )
        ..addCallHandler(
          ConnectionChannel.ON_DEVICE_DISCONNECTED,
          (arguments) {
            final device = DeviceInfo.fromJson(arguments!['device']);
            onDeviceRemove(device);
          },
        );
    } else {
      ConnectionPlugin().subscribeDeviceChanges(onDeviceAdd, onDeviceRemove);
    }
  }

  @override
  void removeDeviceChangeListener() {
    if (Platform.isAndroid) {
      UnisyncChannels.connection
        ..removeHandler(ConnectionChannel.ON_DEVICE_CONNECTED)
        ..removeHandler(ConnectionChannel.ON_DEVICE_DISCONNECTED);
    } else {
      ConnectionPlugin().unsubscribeDeviceChanges();
    }
  }

  @override
  Future<void> connectToAddress(String ipAddress) async {
    if (Platform.isAndroid) {
      UnisyncChannels.connection.invokeMethod(
        ConnectionChannel.ADD_DEVICE_MANUALLY,
        arguments: {'ip': ipAddress},
      );
    }
  }

  @override
  Future<List<DeviceInfo>> getAvailableDevices() async {
    if (Platform.isAndroid) {
      final devices = (await UnisyncChannels.connection.invokeMethod(ConnectionChannel.GET_CONNECTED_DEVICES)).result as List<String>;
      return devices.map((e) => DeviceInfo.fromJson(e.toMap())).toList();
    } else {
      return DeviceEntryPoint.devices;
    }
  }
}
