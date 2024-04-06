import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:unisync/utils/logger.dart';

Future<Uint8List> handlePayload({
  required String address,
  required int port,
  required int size,
}) async {
  debugLog('Start receiving payload from $address:$port...');
  return Isolate.run<Uint8List>(() async {
    final completer = Completer<Uint8List>();
    try {
      final socket = await Socket.connect(address, port);
      final Uint8List data = Uint8List(size);
      var progress = 0;
      infoLog('Progress: 0%');
      socket.listen((event) {
        data.setRange(progress, progress + event.length, event);
        progress += event.length;
        infoLog('Progress: ${(progress / size) * 100}%');
        if (progress == size) {
          socket.close();
          completer.complete(data);
        }
      });
    } on Exception catch (e) {
      completer.completeError(e);
    }
    return completer.future;
  });
}
