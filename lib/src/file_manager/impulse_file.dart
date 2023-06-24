import 'dart:io';

import 'package:impulse_utils/src/file_manager/utils.dart';
import 'package:impulse_utils/src/models/file_size.dart';

abstract interface class ImpulseFileEntity extends FileSize {
  final FileSystemEntity fileSystemEntity;

  const ImpulseFileEntity({
    required int size,
    required this.fileSystemEntity,
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

  ImpulseFileType? get fileType {
    if (isFolder) return null;
    return fileSystemEntity.path.getFileType;
  }

  String get name {
    return fileSystemEntity.path.split("/").last;
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
      : super(size: size, fileSystemEntity: file);

  int get totalFileSize {
    final f = File(file.path);
    return f.lengthSync();
  }
}
