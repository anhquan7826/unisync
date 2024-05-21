// ignore_for_file: non_constant_identifier_names

import 'package:unisync/core/device.dart';
import 'package:unisync/core/device_connection.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/core/plugins/storage/file_server.dart';
import 'package:unisync/core/plugins/storage/sftp_client.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/models/file/file.model.dart';
import 'package:unisync/utils/extensions/stream.ext.dart';
import 'package:unisync/utils/file_util.dart';
import 'package:unisync/utils/payload_handler.dart';
import 'package:unisync/utils/push_notification.dart';

class StoragePlugin extends UnisyncPlugin {
  StoragePlugin(Device device)
      : super(device, type: DeviceMessage.Type.STORAGE);

  static const _method = (
    START_SERVER: 'start_server',
    STOP_SERVER: 'stop_server',
    LIST_DIR: 'list_dir',
    SEND_FILE: 'send_file',
    GET_FILE: 'get_file',
  );

  @override
  void onReceive(
    DeviceMessageHeader header,
    Map<String, dynamic> data,
    Payload? payload,
  ) {
    super.onReceive(header, data, payload);
    if (header.method == _method.LIST_DIR) {
      _server.listDirectory(data['path']).then((value) {
        sendResponse(
          _method.LIST_DIR,
          data: {'dir': value.map((e) => e.toJson()).toList()},
        );
      });
    }
    if (header.method == _method.SEND_FILE) {
      getPayloadData(
        payload!.stream,
        size: payload.size,
        onProgress: (progress) {},
      ).then((value) {
        FileUtil.saveToDesktop(
          data['name'],
          value,
        ).whenComplete(() {
          PushNotification.showNotification(
            title: 'File saved to Desktop!',
            text: data['name'],
          );
        });
      });
    }
    if (header.method == _method.GET_FILE) {
      _server.getSize(data['path']).then((size) {
        sendResponse(
          _method.GET_FILE,
          data: {},
          payload: Payload(
            size,
            _server.read(data['path']),
          ),
        );
      });
    }
  }

  final _server = FileServer();
  UnisyncSFTPClient? _client;

  Future<void> startServer() {
    final c = completer();
    sendRequest(_method.START_SERVER);
    messages.listenCancellable((event) {
      if (event.header.type == DeviceMessageHeader.Type.RESPONSE) {
        if (event.header.method == _method.START_SERVER) {
          final port = event.data['port'] as int;
          final username = event.data['username'] as String;
          final password = event.data['password'] as String;
          _client = UnisyncSFTPClient(
            address: device.ipAddress!,
            port: port,
            username: username,
            password: password,
          );
          _client!.connect().whenComplete(() {
            complete(c, value: null);
          });
        } else if (event.header.status == DeviceMessageHeader.Status.ERROR) {
            completeError(c, error: Exception('No permission!'));
        }
        return true;
      }
      return false;
    });
    return future(c);
  }

  void stopServer() {
    sendRequest(_method.STOP_SERVER);
    _client = null;
  }

  Future<List<UnisyncFile>> list(String path) async {
    return (await _client!.list(path)).map((e) {
      return UnisyncFile(
        name: e.filename,
        type: () {
          if (e.attr.isDirectory) {
            return UnisyncFile.Type.DIRECTORY;
          }
          if (e.attr.isSymbolicLink) {
            return UnisyncFile.Type.SYMLINK;
          }
          return UnisyncFile.Type.FILE;
        }.call(),
        size: e.attr.size ?? -1,
        fullPath: '${path.replaceAll(RegExp(r' / $'), '')}/${e.filename}',
      );
    }).toList();
  }

  Future<void> put(String remoteDest, String localSource, {void Function(double)? onProgress}) =>
      _client!.put(remoteDest, localSource, onProgress: onProgress);

  Future<void> get(String remoteSource, String localDest, {void Function(double)? onProgress}) =>
      _client!.get(remoteSource, localDest, onProgress: onProgress);
}
