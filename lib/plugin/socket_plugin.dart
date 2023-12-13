// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:unisync/constants/network_ports.dart';
import 'package:unisync/entry/device_entry_point.dart';
import 'package:unisync/plugin/unisync_plugin.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/logger.dart';

class SocketPlugin extends UnisyncPlugin {
  static SocketPluginHandler getHandler() {
    return SocketPluginHandler();
  }

  final Map<String, SecureServerSocket> _serverSockets = {};

  @override
  Future<void> start() async {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        await _createServerSocket(address.address);
      }
    }
    _createServerSocket('127.0.0.1');
  }

  Future<void> _createServerSocket(String address) async {
    final context = SecurityContext.defaultContext
      ..useCertificateChainBytes(ConfigUtil.authentication.getCertificate().codeUnits)
      ..usePrivateKeyBytes(ConfigUtil.authentication.getPrivateKeyString().codeUnits);
    _serverSockets[address] = await SecureServerSocket.bind(address, NetworkPorts.socketPort, context);
    infoLog('AppSocket: Created server socket on $address.');
    _serverSockets[address]?.listen((socket) {
      infoLog('AppSocket: New connection established to ${socket.address.address}.');
      DeviceEntryPoint.createConnection(SocketConnection(socket));
    });
  }

  @override
  Future<void> stop() async {
    for (final element in _serverSockets.values) {
      await element.close();
    }
  }
}

class SocketPluginHandler extends UnisyncPluginHandler {}

enum SocketConnectionState { STATE_CONNECTED, STATE_DISCONNECTED }

class SocketConnection {
  SocketConnection(this._socket) {
    _initialize();
  }

  final Socket _socket;
  final ReplaySubject<String> _inputStream = ReplaySubject();
  final ReplaySubject<SocketConnectionState> _stateStream = ReplaySubject();

  bool _isConnected = true;

  bool get isConnected => _isConnected;

  late final String _address = _socket.address.address;

  String get address => _address;

  void _initialize() {
    _socket.listen(
      (data) {
        final message = String.fromCharCodes(data).trim();
        debugLog('SocketConnection@${_socket.address.address}: Incoming message: "$message".');
        _inputStream.add(message);
      },
      onDone: () {
        debugLog('SocketConnection@${_socket.address.address}: Disconnected.');
        _isConnected = false;
        _stateStream.add(SocketConnectionState.STATE_DISCONNECTED);
        _inputStream.close();
        _stateStream.close();
      },
      cancelOnError: true,
    );
    _stateStream.add(SocketConnectionState.STATE_CONNECTED);
  }

  Future<void> disconnect() async {
    await _socket.flush();
    await _socket.close();
  }

  Stream<String> getInputStream() {
    return _inputStream.stream;
  }

  Stream<SocketConnectionState> getConnectionState() {
    return _stateStream.stream;
  }

  Future<void> send(String data) async {
    if (!_isConnected) {
      throw Exception('Connection to $_address has been closed!');
    } else {
      _socket.writeln(data);
      debugLog('SocketConnection@${_socket.address.address}: Sent message: "$data".');
    }
  }
}
