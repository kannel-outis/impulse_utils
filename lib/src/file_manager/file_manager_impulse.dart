import 'dart:io';

import 'package:impulse_utils/impulse_utils.dart';
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

  Future<List<FileSystemEntity>> _useRootIfNull(Directory? dir) async {
    final listSync = <FileSystemEntity>[];

    if (dir == null) {
      return _rootDir;
    } else {
      await for (final entity in dir.list()) {
        listSync.add(entity);
      }
      return listSync;
    }
  }

  Future<List<ImpulseFileEntity>> getFileInDirAsync(
      [ImpulseFileEntity? folder]) async {
    final directories = <ImpulseDirectory>[];
    final files = <ImpulseFile>[];
    if (folder == null && Platform.isAndroid) {
      for (var path in rootPath) {
        final rootInfo = await ImpulseUtils().getStorageInfo(path);
        if (rootInfo != null) {
          directories.add(rootInfo);
        }
      }
      return directories;
    }
    final dir = (folder?.fileSystemEntity as Directory?);
    final listAsync = await _useRootIfNull(dir);
    /*
      * if dir is null that means we are loading the root and should not be sorted
      * this makes the phone storage to come first as it has a longer path which will
      * cause it to come last if sorted.
    */

    final isRoot = dir == null;
    if (isRoot == false) {
      listAsync
          .sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    }
    for (var item in listAsync) {
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
