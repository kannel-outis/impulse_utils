import 'dart:io';

import 'package:impulse_utils/file_manager/utils.dart';

class ImpulseFileSystem {
  final FileSystemEntity file;
  const ImpulseFileSystem({
    required this.file,
  });

  bool get isFolder => file is Directory;

  int? get numberOfItemsInFolder {
    if (isFolder) {
      final dir = file as Directory;
      if (!dir.existsSync()) return null;
      return dir.listSync().length;
    }
    return null;
  }

  int? get totalFileSize {
    if (isFolder) return null;
    final f = File(file.path);
    if (!f.existsSync()) return null;
    return f.lengthSync();
  }

  ImpulseFileType? get fileType {
    if (isFolder) return null;
    return file.path.getFileType;
  }

  String get name {
    return file.path.split("/").last;
  }
}
