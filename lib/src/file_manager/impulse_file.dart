import 'dart:convert';
import 'dart:io';

import 'package:impulse_utils/src/file_manager/utils.dart';
import 'package:impulse_utils/src/models/file_size.dart';

abstract interface class ImpulseFileEntity extends FileSize {
  final FileSystemEntity fileSystemEntity;
  // final bool isRoot;

  const ImpulseFileEntity({
    required int size,
    required this.fileSystemEntity,
    // this.isRoot = false,
  }) : super(size);

  bool get isFolder => fileSystemEntity is Directory;

  int? get numberOfItemsInFolder {
    if (isFolder) {
      final dir = fileSystemEntity as Directory;
      if (!dir.existsSync()) return null;
      return dir.listSync().length;
    }
    return null;
  }

  bool get isRoot => this is ImpulseFileStorage;

  // String? get rootName => isRoot
  //     ? fileSystemEntity.path.contains("emulated")
  //         ? "Phone Storage"
  //         : "Sd card"
  //     : null;
  // bool get isPhoneStorageRoot =>
  //     isRoot && fileSystemEntity.path.contains("emulated");

  ImpulseFileType? get fileType {
    if (isFolder) return null;
    return fileSystemEntity.path.getFileType;
  }

  String get name {
    final names = fileSystemEntity.path.split(Platform.pathSeparator);
    names.removeWhere((element) => element == "");
    return names.last;
  }

  ImpulseFile get castToFile {
    return this as ImpulseFile;
  }
}

class ImpulseDirectory extends ImpulseFileEntity {
  final Directory directory;
  const ImpulseDirectory({required this.directory})
      : super(fileSystemEntity: directory, size: 0);
}

class ImpulseFile extends ImpulseFileEntity {
  final File file;
  const ImpulseFile({required this.file, required int size})
      : super(
          size: size,
          fileSystemEntity: file,
        );

  int get totalFileSize {
    final f = File(file.path);
    return f.lengthSync();
  }
}

class ImpulseFileStorage extends ImpulseDirectory {
  final int totalSize;
  final FileStorageType type;
  final int usedSize;
  final String path;
  ImpulseFileStorage({
    required this.path,
    required this.totalSize,
    required this.type,
    required this.usedSize,
  }) : super(directory: Directory(path));
  int get remainingSize => totalSize - usedSize;
  FileSizeObj get totalSizeToFileSize => FileSizeObj(totalSize);
  FileSizeObj get usedSizeToFileSize => FileSizeObj(usedSize);
  FileSizeObj get remainingSizeToFileSize => FileSizeObj(remainingSize);

  factory ImpulseFileStorage.fromMap(Map<String, dynamic> map) {
    final freeSize = map["freeSize"] as int;
    final totalSize = map["totalSize"] as int;
    final path = map["path"] as String;
    return ImpulseFileStorage(
      path: path,
      totalSize: totalSize,
      type: path.contains("emulated")
          ? FileStorageType.Internal
          : FileStorageType.External,
      usedSize: totalSize - freeSize,
    );
  }

  @override
  String toString() {
    return jsonEncode({
      "path": path,
      "totalSize": totalSize,
      "usedSize": usedSize,
      "type": type.label,
    });
  }
}
