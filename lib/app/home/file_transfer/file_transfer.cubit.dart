import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/file_transfer/file_transfer.state.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/storage/storage.plugin.dart';
import 'package:unisync/models/file/file.model.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';

class FileTransferCubit extends Cubit<FileTransferState> with BaseCubit {
  FileTransferCubit(this.device) : super(const FileTransferState()) {
    _plugin.startServer().whenComplete(() {
      _plugin.to(state.path).then((value) {
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
      path:
          state.path != '/' ? '${state.path}/$folder' : '${state.path}$folder',
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
      path: state.path.lastIndexOf('/').let((it) {
        return (it == 0) ? '/' : state.path.substring(0, it);
      }),
    ));
    final dir = await toDir(state.path);
    safeEmit(state.copyWith(
      status: Status.loaded,
      currentDirectory: dir,
    ));
  }

  Future<List<UnisyncFile>> toDir(String path) async {
    return _plugin.to(path);
  }

  Future<void> getFiles(String name) async {
    final dest = await FilePicker.platform.saveFile(
      dialogTitle: 'Choose destination path...',
      fileName: name,
    );
    if (dest != null) {
      await _plugin.get(
        name,
        dest,
        onProgress: (progress) {

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
        name,
        path,
        onProgress: (progress) {

        },
      );
    }
  }
}
