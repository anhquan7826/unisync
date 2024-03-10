import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:unisync/utils/extensions/map.ext.dart';
import 'package:unisync/utils/extensions/string.ext.dart';
import 'package:unisync/utils/extensions/uint8list.ext.dart';

import '../models/device_message/device_message.model.dart';

mixin ConnectionListener {
  void onMessage(DeviceMessage message);

  void onDisconnected();
}

class DeviceConnection {
  DeviceConnection(this._socket, this._inputStream, [this._onDisconnect]) {
    _listenInputStream();
  }

  final SecureSocket _socket;
  final Stream<Uint8List> _inputStream;
  final void Function()? _onDisconnect;

  var _isConnected = true;

  late final StreamSubscription<Uint8List> _streamSubscription;

  ConnectionListener? connectionListener;

  String get ipAddress => _socket.address.address;

  void _listenInputStream() {
    _streamSubscription = _inputStream.listen(
      (event) {
        connectionListener?.onMessage(DeviceMessage.fromJson(event.string.toMap()));
      },
      cancelOnError: true,
      onDone: disconnect,
    );
  }

  void send(DeviceMessage message) {
    if (_isConnected) {
      _socket.writeln(message.toJson().toJsonString());
    }
  }

  Future<void> disconnect() async {
    _isConnected = false;
    await _streamSubscription.cancel();
    await _socket.close();
    _onDisconnect?.call();
    connectionListener?.onDisconnected();
  }
}
