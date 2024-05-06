import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/models/file/file.model.dart';

part 'file_transfer.state.freezed.dart';

@freezed
class FileTransferState with _$FileTransferState {
  const factory FileTransferState({
    @Default(Status.loading) Status status,
    @Default('/') String path,
    @Default([])List<UnisyncFile> currentDirectory,
    @Default({}) Map<String, double> uploads,
    @Default({}) Map<String, double> downloads,
  }) = _FileTransferState;
}
