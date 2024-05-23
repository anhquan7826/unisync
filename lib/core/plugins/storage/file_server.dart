import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:unisync/models/file/file.model.dart';
import 'package:unisync/utils/file_util.dart';
import 'package:unisync/utils/logger.dart';

class FileServer {
  final _root = '${Platform.environment['HOME']}/';

  String _actualPath(String path) {
    return path.replaceFirst('/', _root);
  }

  String _relativePath(String path) {
    return path.replaceFirst(_root, '/');
  }

  Future<List<UnisyncFile>> listDirectory(String path) async {
    try {
      final dir = Directory(_actualPath(path));
      final list = (await dir.list().toList()).where((element) {
        return !basename(element.path).startsWith('.');
      });
      final List<UnisyncFile> files = [];
      for (final e in list) {
        files.add(UnisyncFile(
          name: basename(e.path),
          type: () {
            if (e is Directory) {
              return UnisyncFile.Type.DIRECTORY;
            }
            if (e is Link) {
              return UnisyncFile.Type.SYMLINK;
            }
            return UnisyncFile.Type.FILE;
          }.call(),
          size: (e is File) ? e.statSync().size : -1,
          fullPath: _relativePath(e.path),
        ));
      }
      return _sort(files);
    } on Exception catch (e) {
      errorLog(e);
      return [];
    }
  }

  Stream<Uint8List> read(String path) async* {
    final file = File(_actualPath(path));
    final stat = file.statSync();
    final access = await file.open();
    final size = stat.size;
    var byteRead = 0;
    try {
      while (byteRead < size) {
        final bytesToRead = (size - byteRead) < 4096 ? (size - byteRead) : 4096;
        await access.setPosition(byteRead);
        yield await access.read(bytesToRead);
        byteRead += bytesToRead;
      }
    } finally {
      await access.close();
    }
  }

  Future<int> getSize(String path) {
    return FileUtil.getFileSize(_actualPath(path));
  }

  Future<void> write(String destination, Stream<Uint8List> data) async {
    final access = await File(destination).open(mode: FileMode.write);
    int byteWritten = 0;
    try {
      await for (final chunk in data) {
        final bytesToWrite = chunk.length > 4096 ? 4096 : chunk.length;
        access.writeFrom(chunk, byteWritten, bytesToWrite);
        byteWritten += bytesToWrite;
      }
    } finally {
      await access.close();
    }
  }

  List<UnisyncFile> _sort(List<UnisyncFile> list) {
    final folder = list.where((element) {
      return element.type == UnisyncFile.Type.DIRECTORY ||
          element.type == UnisyncFile.Type.SYMLINK;
    }).toList()
      ..sort((a, b) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    final files = list.where((element) {
      return element.type == UnisyncFile.Type.FILE;
    }).toList()
      ..sort((a, b) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return [
      ...folder,
      ...files,
    ];
  }
}
