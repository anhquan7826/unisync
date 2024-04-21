import 'dart:io';
import 'dart:typed_data';

class FileUtil {
  FileUtil._();

  static final _root = '${Platform.environment['HOME']}/';

  static Future<void> saveToDesktop(String name, Uint8List data) async {
    await File('${_root}Desktop/$name').writeAsBytes(data, flush: true);
  }

  static Future<int> getFileSize(String path) async {
    return File(path).length();
  }
}