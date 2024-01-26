import 'dart:io';

import 'package:unisync_backend/core/device_provider.dart';
import 'package:unisync_backend/models/channel_result/channel_result.model.dart';
import 'package:unisync_backend/models/device_info/device_info.model.dart';
import 'package:unisync_backend/notification/event_notifier.dart';
import 'package:unisync_backend/notification/events/device_connected.event.dart';
import 'package:unisync_backend/notification/events/device_disconnected.event.dart';
import 'package:unisync_backend/notification/handlers/device_connected.event_handler.dart';
import 'package:unisync_backend/notification/handlers/device_disconnected.event_handler.dart';
import 'package:unisync_backend/utils/channels.dart';
import 'package:unisync_backend/utils/extensions/string.ext.dart';

import 'devices.repo.dart';

class DevicesRepositoryImpl implements DevicesRepository, DeviceConnectedEventHandler, DeviceDisconnectedEventHandler {
  @override
  Future<List<DeviceInfo>> getConnectedDevices() async {
    if (Platform.isAndroid) {
      final devices = (await UnisyncChannel(UnisyncChannel.DEVICES).invoke('getConnectedDevices')).result as List;
      return devices.map((e) => DeviceInfo.fromJson(e.toString().toMap())).toList();
    } else {
      return DeviceProvider.devices;
    }
  }

  final _listeners = <DevicesRepositoryConnectionListener>{};

  @override
  void registerConnectionListener(DevicesRepositoryConnectionListener listener) {
    if (_listeners.isEmpty) {
      if (Platform.isAndroid) {
        UnisyncChannel(UnisyncChannel.DEVICES).addCallHandler('onDeviceConnected', (arguments) {
          final device = DeviceInfo.fromJson(arguments!['device'].toString().toMap());
          for (final listener in _listeners) {
            listener.onConnected(device);
          }
          return ChannelResult(method: 'onDeviceConnected', resultCode: ChannelResult.SUCCESS);
        });
        UnisyncChannel(UnisyncChannel.DEVICES).addCallHandler('onDeviceDisconnected', (arguments) {
          final device = DeviceInfo.fromJson(arguments!['device'].toString().toMap());
          for (final listener in _listeners) {
            listener.onConnected(device);
          }
          return ChannelResult(method: 'onDeviceDisconnected', resultCode: ChannelResult.SUCCESS);
        });
      } else {
        UnisyncEventNotifier.register(this);
      }
    }
    _listeners.add(listener);
  }

  @override
  void unregisterConnectionListener(DevicesRepositoryConnectionListener listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty) {
      if (Platform.isAndroid) {
        UnisyncChannel(UnisyncChannel.DEVICES).removeHandler('onDeviceConnected');
        UnisyncChannel(UnisyncChannel.DEVICES).removeHandler('onDeviceDisconnected');
      } else {
        UnisyncEventNotifier.unregister(this);
      }
    }
  }

  @override
  void onDeviceConnectedEvent(DeviceConnectedEvent event) {
    for (final listener in _listeners) {
      listener.onConnected(event.device);
    }
  }

  @override
  void onDeviceDisconnectedEvent(DeviceDisconnectedEvent event) {
    for (final listener in _listeners) {
      listener.onDisconnected(event.device);
    }
  }

  @override
  void connectToDevice(String ip) {
    if (Platform.isAndroid) {
      // UnisyncChannel(UnisyncChannel.DEVICES).invoke();
    }
  }
}
