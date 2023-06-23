import 'dart:io';

import 'package:impulse_utils/src/file_manager/utils.dart';
import 'package:impulse_utils/src/models/file_size.dart';

abstract interface class ImpulseFileEntity extends FileSize {
  final FileSystemEntity file;
  const ImpulseFileEntity({
    required int size,
    required this.file,
  }) : super(size);

  bool get isFolder => file is Directory;

  int? get numberOfItemsInFolder {
    if (isFolder) {
      final dir = file as Directory;
      if (!dir.existsSync()) return null;
      return dir.listSync().length;
    }
    return null;
  }

  ImpulseFileType? get fileType {
    if (isFolder) return null;
    return file.path.getFileType;
  }

  String get name {
    return file.path.split("/").last;
  }

  ImpulseFile get castToFile {
    return this as ImpulseFile;
  }
}

class ImpulseDirectory extends ImpulseFileEntity {
  const ImpulseDirectory({required Directory directory})
      : super(file: directory, size: 0);
}

class ImpulseFile extends ImpulseFileEntity {
  const ImpulseFile({required File file, required int size})
      : super(size: size, file: file);

  int get totalFileSize {
    final f = File(file.path);
    return f.lengthSync();
  }
}
