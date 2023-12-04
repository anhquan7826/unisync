// ignore_for_file: sort_constructors_first, constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:unisync/backend/socket/socket.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/extensions/map.ext.dart';
import 'package:unisync/utils/logger.dart';

class DeviceConnection {
  static final Map<String, DeviceConnection> _connections = {};

  static List<DeviceConnection> get connections => _connections.values.toList();

  static void createConnection(SocketConnection socket) {
    DeviceConnection._(socket);
  }

  // ignore: close_sinks
  static final ReplaySubject<ConnectionNotifierValue> connectionNotifier = ReplaySubject();

  DeviceConnection._(this._socket) {
    initialize();
  }

  Future<void> initialize() async {
    _socket.getConnectionState().listen((event) async {
      switch (event) {
        case SocketConnectionState.STATE_CONNECTED:
          _socket.send((await ConfigUtil.device.getDeviceInfo()).toJson().toJsonString());
          _socket.getInputStream().listen(_onInputData);
          break;
        case SocketConnectionState.STATE_DISCONNECTED:
          if (info != null) {
            _onDeviceOffline();
          }
          break;
      }
    });
  }

  final SocketConnection _socket;
  // ignore: close_sinks
  final ReplaySubject<String> messageNotifier = ReplaySubject();
  DeviceInfo? info;

  void _onInputData(String input) {
    if (info == null) {
      try {
        info = DeviceInfo.fromJson(jsonDecode(input)).copy(ip: _socket.address);
        _onDeviceOnline();
      } catch (_) {
        _socket.disconnect();
      }
    } else {
      messageNotifier.add(input);
    }
  }

  void _onDeviceOnline() {
    if (_connections.containsKey(info!.id)) {
      debugLog('Found duplicate connection to device: ${info!.name} (${info!.ip})');
      _socket.disconnect();
    } else {
      _connections[info!.id] = this;
      connectionNotifier.add(ConnectionNotifierValue(DeviceState.ONLINE, info!));
    }
  }

  void _onDeviceOffline() {
    _connections.remove(info!.id);
    connectionNotifier.add(ConnectionNotifierValue(DeviceState.OFFLINE, info!));
  }
}

enum DeviceState { ONLINE, OFFLINE, MESSAGE_RECEIVED, MESSAGE_SENT }

class ConnectionNotifierValue {
  ConnectionNotifierValue(this.state, this.device);

  final DeviceState state;
  final DeviceInfo device;
}
