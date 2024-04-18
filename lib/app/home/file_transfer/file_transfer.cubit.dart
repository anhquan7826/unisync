import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:file_picker/file_picker.dart' hide FileType;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/file_transfer/file_transfer.state.dart';
import 'package:unisync/components/enums/file_type.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/storage/storage.plugin.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';
import 'package:unisync/utils/logger.dart';

class FileTransferCubit extends Cubit<FileTransferState> with BaseCubit {
  FileTransferCubit(this.device) : super(const FileTransferState()) {
    device.getPlugin<StoragePlugin>().startServer().then((value) {
      _initClient(value.$1, value.$2, value.$3);
    });
  }

  final Device device;
  late final SftpClient _client;

  Future<void> _initClient(int port, String username, String password) async {
    _client = await SSHClient(
      await SSHSocket.connect(device.ipAddress!, port),
      username: username,
      onPasswordRequest: () => password,
    ).sftp();
    final dir = await getDir(state.path);
    safeEmit(state.copyWith(
      status: Status.loaded,
      currentDirectory: dir,
    ));
  }

  Future<void> goToFolder(String folder) async {
    safeEmit(state.copyWith(
      status: Status.loading,
      path:
          state.path != '/' ? '${state.path}/$folder' : '${state.path}$folder',
      currentDirectory: [],
    ));
    final dir = await getDir(state.path);
    safeEmit(state.copyWith(
      status: Status.loaded,
      currentDirectory: dir,
    ));
  }

  Future<void> goBack() async {
    safeEmit(state.copyWith(
      status: Status.loading,
      path: state.path.lastIndexOf('/').let((it) {
        return (it == 0) ? '/' : state.path.substring(0, it);
      }),
    ));
    final dir = await getDir(state.path);
    safeEmit(state.copyWith(
      status: Status.loaded,
      currentDirectory: dir,
    ));
  }

  Future<List<({String name, FileType type})>> getDir(String path) async {
    try {
      final dir = await _client.listdir(path);
      return dir.skipWhile((value) => value.filename.startsWith('.')).map((e) {
        return (
          name: e.filename,
          type: () {
            if (e.attr.isDirectory) {
              return FileType.directory;
            }
            if (e.attr.isSymbolicLink) {
              return FileType.symlink;
            }
            return FileType.file;
          }.call()
        );
      }).toList()
        ..sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
    } catch (_) {
      return [];
    }
  }

  Future<void> getFiles(String name) async {
    final file = await _client.open(
      '${state.path != '/' ? '${state.path}/' : '/'}$name',
    );
    final dest = await FilePicker.platform.saveFile(
      dialogTitle: 'Choose destination path...',
      fileName: name,
    );
    if (dest != null) {
      final fileDest = File(dest).openWrite();
      file.read(onProgress: (p) => debugLog('Progress: $p')).listen(
        (event) {
          fileDest.write(event);
        },
        onDone: () {
          fileDest.close();
        },
      );
    }
  }

  Future<void> putFile() async {
    final pickerResult = await FilePicker.platform.pickFiles(
      dialogTitle: 'Choose file to upload...',
    );
    final filePath = pickerResult?.files.firstOrNull?.path;
    final fileName = pickerResult?.files.firstOrNull?.name;
    if (filePath != null && fileName != null) {
      final file = File(filePath);
      debugLog('${state.path != '/' ? '${state.path}/' : '/'}$fileName');
      final destFile = await _client.open(
        '${state.path != '/' ? '${state.path}/' : '/'}$fileName',
        mode: SftpFileOpenMode.create | SftpFileOpenMode.write,
      );
      destFile.write(file.openRead().cast(),
          onProgress: (p) => debugLog('Progress: $p'));
    }
  }
}
