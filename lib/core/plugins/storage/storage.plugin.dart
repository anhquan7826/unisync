// ignore_for_file: non_constant_identifier_names

import 'package:dartssh2/dartssh2.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/core/plugins/storage/sftp_client.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/extensions/stream.ext.dart';

class StoragePlugin extends UnisyncPlugin {
  StoragePlugin(Device device)
      : super(device, type: DeviceMessage.Type.STORAGE);
  static const _method = (
    START_SERVER: 'start_server',
    STOP_SERVER: 'stop_server',
  );

  UnisyncSFTPClient? _client;

  Future<void> startServer() {
    final c = completer();
    sendRequest(_method.START_SERVER);
    messages.listenCancellable((event) {
      if (event.header.type == DeviceMessageHeader.Type.RESPONSE &&
          event.header.method == _method.START_SERVER) {
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
        return true;
      }
      return false;
    });
    return future(c);
  }

  Future<void> stopServer() async {
    sendRequest(_method.STOP_SERVER);
  }

  Future<List<SftpName>> to(String dir) => _client!.to(dir);

  Future<List<SftpName>> back() => _client!.back();

  Future<void> put({void Function(double)? onProgress}) =>
      _client!.put(onProgress: onProgress);

  Future<void> get(String name, {void Function(double)? onProgress}) =>
      _client!.get(name, onProgress: onProgress);

  String get currentPath => _client!.currentDir;
}
