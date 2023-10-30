import 'dart:convert';

import 'package:unisync/backend/socket/socket.dart';
import 'package:unisync/extensions/map.ext.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/configs.dart';

class DeviceConnection {
  DeviceConnection._(this._socket) {
    inititalize();
  }

  static final List<DeviceConnection> _connections = [];

  static void createConnection(SocketConnection socket) {
    _connections.add(DeviceConnection._(socket));
  }

  static List<DeviceInfo> getConnectedDevices() {
    return _connections.map((e) => e._info).whereType<DeviceInfo>().toList();
  }

  static List<DeviceInfo> getUnpairedDevice() {
    return _connections.where((element) => !element.isPaired).map((e) => e._info).whereType<DeviceInfo>().toList();
  }

  Future<void> inititalize() async {
    _socket.getConnectionState().listen((event) async {
      switch (event) {
        case SocketConnectionState.STATE_CONNECTED:
          _socket.send((await AppConfig.device.getDeviceInfo()).toJson().toJsonString());
          _socket.getInputStream().listen(_onInputData);
          break;
        case SocketConnectionState.STATE_DISCONNECTED:
          break;
      }
    });
  }

  final SocketConnection _socket;

  DeviceInfo? _info;
  bool _paired = false;
  bool get isPaired => _paired;

  void _onInputData(String input) {
    _info ??= DeviceInfo.fromJson(jsonDecode(input)).copy(ip: _socket.address);
  }
}
