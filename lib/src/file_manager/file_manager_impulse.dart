import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'impulse_file.dart';

class FileManager {
  FileManager._();
  static FileManager? _instance;

  static FileManager get instance {
    if (_instance == null) {
      _instance = FileManager._();
      return _instance!;
    }
    return _instance!;
  }

  List<String> get rootPath {
    return _rootDir.map((e) => e.path).toList();
  }

  late final List<Directory> _rootDir;

  Future<void> getRootPaths(bool addExternalStorage) async {
    if (addExternalStorage) {
      final dir = await getExternalStorageDirectories();
      _rootDir = _getRootPath(dir!);
      return;
    }
    final dir = await getExternalStorageDirectory() as Directory;
    _rootDir = _getRootPath([dir]);
  }

  List<Directory> _getRootPath(List<Directory> directories) {
    final list = <Directory>[];
    for (final directory in directories) {
      final path = directory.path;
      if (path.contains("emulated")) {
        final splitPath = path.split("/");
        splitPath.removeRange(4, splitPath.length);
        final trimPath = splitPath.join("/");
        list.add(Directory("$trimPath/"));
      } else {
        final splitPath = path.split("/");
        splitPath.removeRange(3, splitPath.length);
        final trimPath = splitPath.join("/");
        list.add(Directory("$trimPath/"));
      }
    }
    return list;
  }

  List<ImpulseFileEntity> getFileInDir([ImpulseFileEntity? folder]) {
    final files = <ImpulseFile>[];
    final directories = <ImpulseDirectory>[];
    final dir = (folder?.fileSystemEntity as Directory?) ?? _rootDir.first;
    final listSync = dir.listSync();
    listSync
        .sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    for (var item in listSync) {
      if (item is File) {
        files.add(ImpulseFile(file: item, size: item.lengthSync()));
      } else {
        directories.add(ImpulseDirectory(directory: item as Directory));
      }
    }

    final list = [...directories, ...files];

    return list;
  }
}
