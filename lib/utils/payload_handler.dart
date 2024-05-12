import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unisync/utils/extensions/stream.ext.dart';
import 'package:unisync/utils/logger.dart';

// Future<Uint8List> handlePayload({
//   required String address,
//   required int port,
//   required int size,
// }) async {
//   debugLog('Start receiving payload from $address:$port...');
//   return Isolate.run<Uint8List>(() async {
//     final completer = Completer<Uint8List>();
//     try {
//       final socket = await Socket.connect(address, port);
//       final Uint8List data = Uint8List(size);
//       var progress = 0;
//       infoLog('Progress: 0%');
//       socket.listen((event) {
//         data.setRange(progress, progress + event.length, event);
//         progress += event.length;
//         infoLog('Progress: ${(progress / size) * 100}%');
//         if (progress == size) {
//           socket.close();
//           completer.complete(data);
//         }
//       });
//     } on Exception catch (e) {
//       completer.completeError(e);
//     }
//     return completer.future;
//   });
// }

Future<Stream<Uint8List>> getPayloadStream({
  required String address,
  required int port,
}) async {
  try {
    infoLog('Connecting to payload server $address:$port...');
    final socket = await Socket.connect(address, port);
    infoLog('Connected to payload server $address:$port.');
    return socket;
  } catch (e) {
    infoLog('Cannot connect to payload server $address:$port.');
    errorLog(e);
    rethrow;
  }
}

Future<Uint8List> getPayloadData(
  Stream<Uint8List> stream, {
  required int size,
  void Function(int)? onProgress,
}) async {
  final completer = Completer<Uint8List>();
  final Uint8List data = Uint8List(size);
  infoLog('Receiving payload of size $size...');
  int progress = 0;
  stream.listenCancellable(
    (event) {
      data.setRange(progress, progress + event.length, event);
      progress += event.length;
      onProgress?.call(progress);
      if (progress == size) {
        completer.complete(data);
        infoLog('Payload of size $size received!');
        return true;
      } else {
        return false;
      }
    },
    onError: (error, stacktrace) {
      errorLog('getPayloadData stopped with error!');
      completer.completeError(
        error,
        stacktrace,
      );
    },
  );
  return completer.future;
}
