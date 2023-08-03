import 'dart:io';

import 'package:impulse_utils/src/file_manager/utils.dart';
import 'package:impulse_utils/src/models/file_size.dart';

abstract interface class ImpulseFileEntity extends FileSize {
  final FileSystemEntity fileSystemEntity;
  final bool isRoot;

  const ImpulseFileEntity({
    required int size,
    required this.fileSystemEntity,
    this.isRoot = false,
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

  String? get rootName => isRoot
      ? fileSystemEntity.path.contains("emulated")
          ? "Phone Storage"
          : "Sd card"
      : null;
  bool get isPhoneStorageRoot =>
      isRoot && fileSystemEntity.path.contains("emulated");

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
  const ImpulseDirectory({required this.directory, bool isRoot = false})
      : super(fileSystemEntity: directory, size: 0, isRoot: isRoot);
}

class ImpulseFile extends ImpulseFileEntity {
  final File file;
  const ImpulseFile(
      {required this.file, required int size, bool isRoot = false})
      : super(size: size, fileSystemEntity: file, isRoot: isRoot);

  int get totalFileSize {
    final f = File(file.path);
    return f.lengthSync();
  }
}
