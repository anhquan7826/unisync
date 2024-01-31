import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:unisync/utils/extensions/map.ext.dart';
import 'package:unisync/utils/extensions/string.ext.dart';
import 'package:unisync/utils/extensions/uint8list.ext.dart';

import '../models/device_info/device_info.model.dart';
import '../models/device_message/device_message.model.dart';
import '../utils/logger.dart';
import 'device_provider.dart';

mixin ConnectionListener {
  void onMessage(DeviceMessage message);

  void onDisconnected();
}

mixin ConnectionEmitter {
  void sendMessage(DeviceMessage message);
}

class DeviceConnection {
  DeviceConnection(this.socket, this.inputStream, this.info) {
    _listenInputStream();
  }

  final SecureSocket socket;
  final Stream<Uint8List> inputStream;
  final DeviceInfo info;

  var _isConnected = true;

  late final StreamSubscription<Uint8List> _streamSubscription;

  ConnectionListener? connectionListener;

  void _listenInputStream() {
    _streamSubscription = inputStream.listen(
      (event) {
        infoLog('DeviceConnection@${info.name}: Message received:');
        infoLog(event.string.toMap());
        connectionListener?.onMessage(DeviceMessage.fromJson(event.string.toMap()));
      },
      cancelOnError: true,
      onDone: disconnect,
    );
  }

  void send(DeviceMessage message) {
    if (_isConnected) {
      socket.writeln(message.toJson().toJsonString());
      infoLog('DeviceConnection@${info.name}: Message sent:');
      infoLog(message.toJson());
    }
  }

  Future<void> disconnect() async {
    _isConnected = false;
    await _streamSubscription.cancel();
    await socket.close();
    connectionListener?.onDisconnected();
    DeviceProvider.remove(info);
    infoLog('DeviceConnection: ${info.name} disconnected!');
  }
}
