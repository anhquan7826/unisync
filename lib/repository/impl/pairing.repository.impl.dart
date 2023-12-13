import 'dart:io';

import 'package:unisync/entry/device_entry_point.dart';
import 'package:unisync/constants/channel_result_code.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/repository/pairing.repository.dart';
import 'package:unisync/utils/channels.dart';
import 'package:unisync/utils/configs.dart';

class PairingRepositoryImpl extends PairingRepository {
  PairingRepositoryImpl() {
    if (Platform.isAndroid) {
      UnisyncChannels.connection
        ..addCallHandler(PairingChannel.ON_DEVICE_CONNECTED, (arguments) {
          final value = (arguments!['device'] as Map).map((key, value) => MapEntry(key.toString(), value));
          final device = DeviceInfo.fromJson(value);
          for (final callback in _callbacks) {
            callback.onDeviceConnected.call(device);
          }
        })
        ..addCallHandler(PairingChannel.ON_DEVICE_DISCONNECTED, (arguments) {
          final value = (arguments!['device'] as Map).map((key, value) => MapEntry(key.toString(), value));
          final device = DeviceInfo.fromJson(value);
          for (final callback in _callbacks) {
            callback.onDeviceDisconnected.call(device);
          }
        });
    } else {
      DeviceEntryPoint.connectionNotifier.listen((value) {
        switch (value.state) {
          case DeviceState.ONLINE:
            for (final callback in _callbacks) {
              callback.onDeviceConnected.call(value.device);
            }
            break;
          case DeviceState.OFFLINE:
            for (final callback in _callbacks) {
              callback.onDeviceDisconnected.call(value.device);
            }
            break;
          default:
            break;
        }
      });
    }
  }

  final List<DeviceStateCallback> _callbacks = [];

  Future<List<DeviceInfo>> getConnectedDevices() async {
    if (Platform.isAndroid) {
      final result = await UnisyncChannels.connection.invokeMethod(PairingChannel.GET_CONNECTED_DEVICES);
      if (result.resultCode == ChannelResultCode.success) {
        return (result.result as List).map((e) {
          return DeviceInfo.fromJson(e);
        }).toList();
      } else {
        return [];
      }
    } else {
      return DeviceEntryPoint.connections.map((e) => e.info!).toList();
    }
  }

  @override
  Future<List<DeviceInfo>> getPairedDevices() async {
    if (Platform.isAndroid) {
      final result = await UnisyncChannels.connection.invokeMethod(PairingChannel.GET_PAIRED_DEVICES);
      if (result.resultCode == ChannelResultCode.success) {
        return (result.result as List).map((e) {
          return DeviceInfo.fromJson((e as Map).cast<String, dynamic>());
        }).toList();
      } else {
        return [];
      }
    } else {
      final connectedDevices = await getConnectedDevices();
      return (await ConfigUtil.device.getPairedDevices()).map((device) {
        final pairedConnectedDevice = () {
          try {
            return connectedDevices.firstWhere((element) => element.id == device.id);
          } catch (_) {
            return null;
          }
        }.call();
        if (pairedConnectedDevice != null) {
          // TODO: save this device if the persisted data is different (changed name or something else)
          return pairedConnectedDevice;
        }
        return device;
      }).toList();
    }
  }

  @override
  Future<List<DeviceInfo>> getUnpairedDevices() async {
    if (Platform.isAndroid) {
      final result = await UnisyncChannels.connection.invokeMethod(PairingChannel.GET_UNPAIRED_DEVICES);
      if (result.resultCode == ChannelResultCode.success) {
        return (result.result as List).map((e) {
          return DeviceInfo.fromJson((e as Map).cast<String, dynamic>());
        }).toList();
      } else {
        return [];
      }
    } else {
      final persistedId = (await ConfigUtil.device.getPairedDevices()).map((e) => e.id);
      return (await getConnectedDevices()).where((element) {
        return !persistedId.contains(element.id);
      }).toList();
    }
  }

  @override
  Future<bool> isDeviceOnline(DeviceInfo device) async {
    if (Platform.isAndroid) {
      final result = await UnisyncChannels.connection.invokeMethod(
        PairingChannel.IS_DEVICE_ONLINE,
        arguments: {'device': device.toJson()},
      );
      if (result.resultCode == ChannelResultCode.success) {
        return result.result == true;
      } else {
        throw Exception(result.error);
      }
    } else {
      return DeviceEntryPoint.connections.any((element) => element.info!.id == device.id);
    }
  }

  @override
  Future<bool> isDevicePaired(DeviceInfo device) async {
    if (Platform.isAndroid) {
      final result = await UnisyncChannels.connection.invokeMethod(
        PairingChannel.IS_DEVICE_PAIRED,
        arguments: {'device': device.toJson()},
      );
      if (result.resultCode == ChannelResultCode.success) {
        return result.result == true;
      } else {
        throw Exception(result.error);
      }
    } else {
      return (await ConfigUtil.device.getPairedDevices()).any((element) => element.id == device.id);
    }
  }

  @override
  void addDeviceStateListener(DeviceStateCallback callback) {
    _callbacks.add(callback);
  }

  @override
  void removeDeviceStateListener(DeviceStateCallback callback) {
    _callbacks.remove(callback);
  }

  @override
  Future<bool> addDeviceManually(String ip) async {
    if (Platform.isAndroid) {
      final result = await UnisyncChannels.connection.invokeMethod(
        PairingChannel.ADD_DEVICE_MANUALLY,
        arguments: {'ip': ip},
      );
      if (result.resultCode == ChannelResultCode.success) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
