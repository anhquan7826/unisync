import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:unisync/utils/extensions/map.ext.dart';
import 'package:unisync/utils/extensions/string.ext.dart';
import 'package:unisync/utils/extensions/uint8list.ext.dart';
import 'package:unisync/utils/logger.dart';
import 'package:unisync/utils/payload_handler.dart';

import '../models/device_message/device_message.model.dart';

mixin ConnectionListener {
  void onMessage(DeviceMessage message, Payload? payload);

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

  String get ipAddress => _socket.remoteAddress.address;

  void _listenInputStream() {
    _streamSubscription = _inputStream.listen(
      (event) async {
        final message = DeviceMessage.fromJson(
          event.string.toMap(),
        );
        debugLog(message);
        if (message.payload != null) {
          final stream = await getPayloadStream(
            address: ipAddress,
            port: message.payload!.port,
          );
          connectionListener?.onMessage(
            message,
            Payload(message.payload!.size, stream),
          );
        } else {
          connectionListener?.onMessage(message, null);
        }
      },
      cancelOnError: true,
      onDone: disconnect,
    );
  }

  Future<void> send(DeviceMessage message, Uint8List? data) async {
    if (_isConnected) {
      final payloadServer = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
      _socket.writeln(
        message
            .copyWith(
              payload: data == null
                  ? null
                  : DeviceMessagePayload(
                      port: payloadServer.port,
                      size: data.length,
                    ),
            )
            .toJson()
            .toJsonString(),
      );
      if (data != null) {
        infoLog('Opening server socket for payload...');
        final payloadSocket = await payloadServer.first;
        infoLog('Payload socket server found a connection!');
        payloadServer.close();
        infoLog('Sending payload of size ${data.length}...');
        payloadSocket
          ..writeAll(data)
          ..flush()
          ..close();
      }
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

class Payload {
  Payload(this.size, this.stream);

  final int size;
  final Stream<Uint8List> stream;
}
