import 'dart:io';

import 'package:unisync/core/device_entry_point.dart';
import 'package:unisync/models/channel_result/channel_result.model.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/plugin/connection.plugin.dart';
import 'package:unisync/repository/connection.repository.dart';
import 'package:unisync/utils/channels.dart';
import 'package:unisync/utils/configs.dart';
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
            final device = DeviceInfo.fromJson((arguments!['device'] as Map).cast<String, dynamic>());
            onDeviceAdd(device);
            return ChannelResult(
              method: ConnectionChannel.ON_DEVICE_CONNECTED,
              resultCode: ChannelResult.SUCCESS,
            );
          },
        )
        ..addCallHandler(
          ConnectionChannel.ON_DEVICE_DISCONNECTED,
          (arguments) {
            final device = DeviceInfo.fromJson((arguments!['device'] as Map).cast<String, dynamic>());
            onDeviceRemove(device);
            return ChannelResult(
              method: ConnectionChannel.ON_DEVICE_DISCONNECTED,
              resultCode: ChannelResult.SUCCESS,
            );
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
      UnisyncChannels.connection.invoke(
        ConnectionChannel.ADD_DEVICE_MANUALLY,
        arguments: {'ip': ipAddress},
      );
    }
  }

  @override
  Future<List<DeviceInfo>> getAvailableDevices() async {
    if (Platform.isAndroid) {
      final devices = ((await UnisyncChannels.connection.invoke(ConnectionChannel.GET_CONNECTED_DEVICES)).result as List).cast<String>();
      return devices.map((e) => DeviceInfo.fromJson(e.toMap())).toList();
    } else {
      return DeviceEntryPoint.devices;
    }
  }

  @override
  Future<DeviceInfo?> getLastUsedDevice() async {
    return ConfigUtil.device.getLastUsedDevice();
  }

  @override
  Future<void> setLastUsedDevice(DeviceInfo device) async {
    ConfigUtil.device.setLastUsedDevice(device);
  }
}
