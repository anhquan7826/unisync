import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:unisync_backend/core/device_provider.dart';
import 'package:unisync_backend/models/device_info/device_info.model.dart';
import 'package:unisync_backend/models/device_message/device_message.model.dart';
import 'package:unisync_backend/utils/extensions/map.ext.dart';
import 'package:unisync_backend/utils/extensions/string.ext.dart';
import 'package:unisync_backend/utils/extensions/uint8list.ext.dart';
import 'package:unisync_backend/utils/logger.dart';

abstract class ConnectionListener {
  void onMessage(DeviceMessage message);
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

  ConnectionListener? messageListener;

  void _listenInputStream() {
    _streamSubscription = inputStream.listen(
      (event) {
        messageListener?.onMessage(DeviceMessage.fromJson(event.string.toMap()));
      },
      cancelOnError: true,
      onDone: disconnect,
    );
  }

  void send(DeviceMessage message) {
    if (_isConnected) {
      socket.writeln(message.toJson().toJsonString());
    }
  }

  Future<void> disconnect() async {
    _isConnected = false;
    await _streamSubscription.cancel();
    await socket.close();
    DeviceProvider.remove(info);
    infoLog('DeviceConnection: ${info.name} disconnected!');
  }
}
