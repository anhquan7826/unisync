import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unisync/components/enums/file_type.dart';
import 'package:unisync/components/enums/status.dart';

part 'file_transfer.state.freezed.dart';

@freezed
class FileTransferState with _$FileTransferState {
  const factory FileTransferState({
    @Default(Status.loading) Status status,
    @Default('/') String path,
    @Default([])List<({String name, FileType type})> currentDirectory,
  }) = _FileTransferState;
}
