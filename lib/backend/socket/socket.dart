// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:unisync/backend/device_connection/device_connection.dart';
import 'package:unisync/constants/network_ports.dart';
import 'package:unisync/utils/logger.dart';

class AppSocket {
  final Map<String, ServerSocket> _serverSockets = {};
  Future<void> start() async {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (!address.isLoopback) {
          await _createServerSocket(address.address);
        }
      }
    }
  }

  Future<void> _createServerSocket(String address) async {
    _serverSockets[address] = await ServerSocket.bind(address, NetworkPorts.socketPort);
    infoLog('AppSocket: Created server socket on $address.');
    _serverSockets[address]?.listen((socket) {
      infoLog('AppSocket: New connection established to ${socket.address.address}.');
      DeviceConnection.createConnection(SocketConnection(socket));
    });
  }
}

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
