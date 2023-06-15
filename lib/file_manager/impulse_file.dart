import 'dart:io';

import 'package:impulse_utils/file_manager/utils.dart';

abstract interface class ImpulseFileEntity {
  final FileSystemEntity file;
  const ImpulseFileEntity({
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
      : super(file: directory);
}

class ImpulseFile extends ImpulseFileEntity {
  const ImpulseFile({required File file}) : super(file: file);

  int get totalFileSize {
    final f = File(file.path);
    return f.lengthSync();
  }

  double get kiloBytes => totalFileSize / 1000;
  double get megaBytes => kiloBytes / 1000;
  double get gigaBytes => megaBytes / 1000;

  String get sizeToString {
    if (gigaBytes >= 1) {
      return "${gigaBytes.toStringAsFixed(1)} GB";
    } else if (megaBytes >= 1) {
      return "${megaBytes.toStringAsFixed(1)} MB";
    } else {
      return "${kiloBytes.toStringAsFixed(1)} KB";
    }
  }
}
