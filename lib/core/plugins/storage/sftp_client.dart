import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:file_picker/file_picker.dart';
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

  bool get connected => _client != null;

  SftpClient? _client;
  String _currentDir = '/';

  String get currentDir => _currentDir;

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
    _client!.close();
  }

  Future<List<SftpName>> to(String dir) async {
    _append(dir);
    return _sort((await _client!.listdir(_currentDir)).skipWhile((value) {
      return value.filename.startsWith('.');
    }).toList());
  }

  Future<List<SftpName>> back() async {
    _remove();
    return _sort((await _client!.listdir(_currentDir)).skipWhile((value) {
      return value.filename.startsWith('.');
    }).toList());
  }

  Future<SftpJob?> get(String name, {void Function(double)? onProgress}) async {
    final file = await _client!.open(_fullPath(name));
    final size = (await file.stat()).size;
    final dest = await FilePicker.platform.saveFile(
      dialogTitle: 'Choose destination path...',
      fileName: name,
    );
    if (dest != null) {
      final fileDest = File(dest).openWrite();
      return SftpJob(
        subscription: file.read(onProgress: (tranfered) {
          onProgress?.call(size == null ? -1 : tranfered / size);
        }).listen(
          (event) {
            fileDest.write(event);
          },
          onDone: () {
            fileDest.close();
          },
        ),
      );
    }
    return null;
  }

  Future<SftpJob?> put({void Function(double)? onProgress}) async {
    final pickerResult = await FilePicker.platform.pickFiles(
      dialogTitle: 'Choose file to upload...',
    );
    final filePath = pickerResult?.files.firstOrNull?.path;
    final fileName = pickerResult?.files.firstOrNull?.name;
    if (filePath != null && fileName != null) {
      final file = File(filePath);
      final size = await file.length();
      final destFile = await _client!.open(
        _fullPath(fileName),
        mode: SftpFileOpenMode.create | SftpFileOpenMode.write,
      );
      return SftpJob(
        writer: destFile.write(
          file.openRead().cast(),
          onProgress: (transfered) {
            onProgress?.call(transfered / size);
          },
        ),
      );
    }
    return null;
  }

  void _append(String directory) {
    assert(!directory.contains('/'), 'Invalid directory!');
    if (_currentDir.endsWith('/')) {
      _currentDir = '$_currentDir$directory';
    } else {
      _currentDir = '$_currentDir/$directory';
    }
    _currentDir = _currentDir.replaceAll(RegExp(r'\/$'), '');
  }

  String _fullPath(String name) {
    String path;
    if (_currentDir.endsWith('/')) {
      path = '$_currentDir$name';
    } else {
      path = '$_currentDir/$name';
    }
    return path.replaceAll(RegExp(r'\/$'), '');
  }

  void _remove() {
    final parts =
        _currentDir.split('/').skipWhile((value) => value.isEmpty).toList();
    if (parts.isEmpty) {
      _currentDir = '/';
      return;
    }
    parts.removeLast();
    _currentDir = '/${parts.join('/')}';
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
