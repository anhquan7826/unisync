// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

part 'file.model.freezed.dart';

part 'file.model.g.dart';

@freezed
class UnisyncFile with _$UnisyncFile {
  const factory UnisyncFile({
    required String name,
    required String type,
    required int size,
    required String fullPath,
  }) = _UnisyncFile;

  factory UnisyncFile.fromJson(Map<String, dynamic> json) =>
      _$UnisyncFileFromJson(json);

  static const Type = (
    DIRECTORY: 'directory',
    FILE: 'file',
    SYMLINK: 'symlink',
  );
}
