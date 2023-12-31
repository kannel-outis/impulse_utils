abstract class FileSize {
  final int size;

  const FileSize(this.size);
  double get kiloBytes => size / 1000;
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

class FileSizeObj extends FileSize {
  FileSizeObj(super.size);
}
