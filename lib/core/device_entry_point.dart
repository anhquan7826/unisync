// ignore_for_file: close_sinks

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/extensions/map.ext.dart';
import 'package:unisync/utils/extensions/string.ext.dart';
import 'package:unisync/utils/extensions/uint8list.ext.dart';
import 'package:unisync/utils/logger.dart';

class DeviceEntryPoint {
  DeviceEntryPoint._();

  static final _devices = <String, DeviceConnection>{};

  static List<DeviceInfo> get devices => _devices.values.map((e) => e.info).toList();

  static final notifiers = _DeviceEntryPointNotifiers._();

  static void create({required SecureSocket socket}) {
    DeviceConnection._(socket: socket);
  }

  static void remove(DeviceInfo info) {
    _devices.remove(info.id);
    notifiers._disconnectedDeviceNotifier.add(info);
  }

  static Future<void> send({
    required String toDeviceId,
    required String plugin,
    required String function,
    Map<String, dynamic> extra = const {},
  }) async {
    await _devices[toDeviceId]?.send(DeviceMessage(
      fromDeviceId: (await ConfigUtil.device.getDeviceInfo()).id,
      plugin: plugin,
      function: function,
      extra: extra,
    ).toJson().toJsonString());
  }
}

class _DeviceEntryPointNotifiers {
  _DeviceEntryPointNotifiers._();

  final _connectedDeviceNotifier = PublishSubject<DeviceInfo>();

  Stream<DeviceInfo> get connectedDeviceNotifier => _connectedDeviceNotifier.asBroadcastStream();

  final _disconnectedDeviceNotifier = PublishSubject<DeviceInfo>();

  Stream<DeviceInfo> get disconnectedDeviceNotifier => _disconnectedDeviceNotifier.asBroadcastStream();

  final _deviceMessageNotifier = PublishSubject<DeviceMessage>();

  Stream<DeviceMessage> get deviceMessageNotifier => _deviceMessageNotifier.asBroadcastStream();
}

class DeviceConnection {
  DeviceConnection._({required this.socket}) {
    _listen();
  }

  final SecureSocket socket;
  late final DeviceInfo info;

  var _isConnected = true;

  late final StreamSubscription<Uint8List> _streamSubscription;

  var _firstEvent = true;

  void _listen() {
    _streamSubscription = socket.listen(
      (event) {
        if (_firstEvent) {
          info = DeviceInfo.fromJson(event.string.toMap()).copy(ip: socket.address.address);
          infoLog('Connected to ${info.name} (${info.ip}).');
          if (!DeviceEntryPoint._devices.containsKey(info.id)) {
            DeviceEntryPoint._devices[info.id] = this;
            DeviceEntryPoint.notifiers._connectedDeviceNotifier.add(info);
          } else {
            warningLog('Duplicate connection to ${info.name} (${info.ip}). Disconnecting...');
            _disconnect();
          }
          _firstEvent = false;
        } else {
          debugLog('Received message from device "${info.name}": ${event.string}');
          DeviceEntryPoint.notifiers._deviceMessageNotifier.add(
            DeviceMessage.fromJson(
              event.string.toMap(),
            ),
          );
        }
      },
      cancelOnError: true,
      onDone: _disconnect,
    );
  }

  Future<void> send(String message) async {
    if (_isConnected) {
    } else {
      throw Exception('Cannot send message to ${info.name}. Connection has closed!');
    }
  }

  Future<void> _disconnect() async {
    _isConnected = false;
    DeviceEntryPoint.remove(info);
    await _streamSubscription.cancel();
    socket.close();
    infoLog('Disconnected from ${info.name} (${info.ip}).');
  }
}
