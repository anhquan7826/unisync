import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:unisync/core/plugins/storage/file_server.dart';
import 'package:unisync/utils/logger.dart';

class UnisyncSFTPClient {
  UnisyncSFTPClient({
    required this.address,
    required this.port,
    required this.username,
    required this.password,
  });

  final String address;
  final int port;
  final String username;
  final String password;

  final FileServer _server = FileServer();
  late final SftpClient _client;

  Future<void> connect() async {
    try {
      _client = await SSHClient(
        await SSHSocket.connect(address, port),
        username: username,
        onPasswordRequest: () => password,
      ).sftp();
    } catch (e) {
      errorLog(e);
    }
  }

  void disconnect() {
    _client.close();
  }

  Future<List<SftpName>> list(String path) async {
    try {
      return _sort((await _client.listdir(path)).skipWhile((value) {
        return value.filename.startsWith('.');
      }).toList());
    } catch (e) {
      errorLog(e);
      return [];
    }
  }

  Future<SftpJob?> get(String remoteSource, String localDest,
      {void Function(double)? onProgress}) async {
    final file = await _client.open(remoteSource);
    final size = (await file.stat()).size;
    final fileDest = File(localDest).openWrite();
    return SftpJob(
      subscription: file.read(onProgress: (transferred) {
        onProgress?.call(size == null ? -1 : transferred / size);
      }).listen(
        (event) {
          fileDest.write(event);
        },
        onDone: () {
          fileDest.close();
        },
      ),
    );
    return null;
  }

  Future<SftpJob?> put(String remoteDest, String filePath,
      {void Function(double)? onProgress}) async {
    final file = File(filePath);
    final size = await file.length();
    final destFile = await _client.open(
      remoteDest,
      mode: SftpFileOpenMode.create | SftpFileOpenMode.write,
    );
    return SftpJob(
      writer: destFile.write(
        file.openRead().cast(),
        onProgress: (transferred) {
          onProgress?.call(transferred / size);
        },
      ),
    );
    return null;
  }

  List<SftpName> _sort(List<SftpName> list) {
    final folder = list.where((element) {
      return element.attr.isDirectory || element.attr.isSymbolicLink;
    }).toList()
      ..sort((a, b) {
        return a.filename.toLowerCase().compareTo(b.filename.toLowerCase());
      });
    final files = list.where((element) {
      return element.attr.isFile;
    }).toList()
      ..sort((a, b) {
        return a.filename.toLowerCase().compareTo(b.filename.toLowerCase());
      });
    return [
      ...folder,
      ...files,
    ];
  }
}

class SftpJob {
  SftpJob({
    SftpFileWriter? writer,
    StreamSubscription<Uint8List>? subscription,
  })  : _subscription = subscription,
        _writer = writer;

  final SftpFileWriter? _writer;
  final StreamSubscription<Uint8List>? _subscription;

  Future<void> cancel() async {
    await _writer?.abort();
    await _subscription?.cancel();
  }
}
