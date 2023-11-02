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
  static final List<DeviceConnection> _connections = [];

  static List<DeviceConnection> get connections => _connections.where((element) => element.info != null).toList();

  static void createConnection(SocketConnection socket) {
    _connections.add(DeviceConnection._(socket));
  }

  // ignore: close_sinks
  static final ReplaySubject<ConnectionNotifierValue> connectionNotifier = ReplaySubject();

  DeviceConnection._(this._socket) {
    inititalize();
  }

  Future<void> inititalize() async {
    _socket.getConnectionState().listen((event) async {
      switch (event) {
        case SocketConnectionState.STATE_CONNECTED:
          _socket.send((await ConfigUtil.device.getDeviceInfo()).toJson().toJsonString());
          _socket.getInputStream().listen(_onInputData);
          break;
        case SocketConnectionState.STATE_DISCONNECTED:
          if (info != null) {
            connectionNotifier.add(ConnectionNotifierValue(DeviceState.OFFLINE, info!));
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
        connectionNotifier.add(ConnectionNotifierValue(DeviceState.ONLINE, info!));
      } catch (_) {
        errorLog('DeviceConnection@${_socket.address}: Invalid initial message.');
      }
    } else {
      messageNotifier.add(input);
      // if (input.contains('"type":"request"')) {
      //   final request = DeviceRequest.fromJson(jsonDecode(input));
      // }
      // if (input.contains('"type":"response"')) {
      //   final response = DeviceResponse.fromJson(jsonDecode(input));
      // }
    }
  }
}

enum DeviceState { ONLINE, OFFLINE, MESSAGE_RECEIVED, MESSAGE_SENT }

class ConnectionNotifierValue {
  ConnectionNotifierValue(this.state, this.device);

  final DeviceState state;
  final DeviceInfo device;
}
