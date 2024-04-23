import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/file_transfer/file_transfer.state.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/storage/storage.plugin.dart';
import 'package:unisync/models/file/file.model.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';
import 'package:unisync/utils/logger.dart';

class FileTransferCubit extends Cubit<FileTransferState> with BaseCubit {
  FileTransferCubit(this.device) : super(const FileTransferState()) {
    _plugin.startServer().whenComplete(() {
      _plugin.list(state.path).then((value) {
        safeEmit(state.copyWith(
          status: Status.loaded,
          currentDirectory: value,
        ));
      });
    });
  }

  final Device device;

  StoragePlugin get _plugin => device.getPlugin<StoragePlugin>();

  Future<void> refresh() async {
    safeEmit(state.copyWith(
      status: Status.loading,
      currentDirectory: [],
    ));
    final dir = await _plugin.list(state.path);
    safeEmit(state.copyWith(
      status: Status.loaded,
      currentDirectory: dir,
    ));
  }

  Future<void> goToFolder(String folder) async {
    safeEmit(state.copyWith(
      status: Status.loading,
      path: _append(folder),
      currentDirectory: [],
    ));
    final dir = await toDir(state.path);
    safeEmit(state.copyWith(
      status: Status.loaded,
      currentDirectory: dir,
    ));
  }

  Future<void> goBack() async {
    safeEmit(state.copyWith(
      status: Status.loading,
      path: _remove(),
    ));
    final dir = await toDir(state.path);
    safeEmit(state.copyWith(
      status: Status.loaded,
      currentDirectory: dir,
    ));
  }

  Future<List<UnisyncFile>> toDir(String path) async {
    return _plugin.list(path);
  }

  Future<void> getFiles(UnisyncFile file) async {
    final dest = await FilePicker.platform.saveFile(
      dialogTitle: 'Choose destination path...',
      fileName: file.name,
    );
    if (dest != null) {
      await _plugin.get(
        file.fullPath,
        dest,
        onProgress: (progress) {
          debugLog('Downloading ${file.name}: ${(progress * 100).toStringAsFixed(2)}%');
        },
      );
    }
  }

  Future<void> putFile() async {
    final pickerResult = await FilePicker.platform.pickFiles(
      dialogTitle: 'Choose file to upload...',
    );
    final path = pickerResult?.files.firstOrNull?.path;
    final name = pickerResult?.files.firstOrNull?.name;
    if (name != null && path != null) {
      await _plugin.put(
        '${state.path}/$name',
        path,
        onProgress: (progress) {
          debugLog('Uploading $name: ${(progress * 100).toStringAsFixed(2)}%');
        },
      );
    }
  }

  String _append(String directory) {
    String newPath;
    if (state.path.endsWith('/')) {
      newPath = '${state.path}$directory';
    } else {
      newPath = '${state.path}/$directory';
    }
    return newPath.replaceAll(RegExp(r'/$'), '');
  }

  String _remove() {
    final parts =
        state.path.split('/').skipWhile((value) => value.isEmpty).toList();
    if (parts.isEmpty) {
      return '/';
    }
    parts.removeLast();
    return '/${parts.join('/')}';
  }
}
