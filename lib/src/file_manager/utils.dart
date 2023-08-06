// ignore_for_file: constant_identifier_names

enum ImpulseFileType {
  mp3("mp3"),
  mp4("mp4"),
  mov("mov"),
  pdf("pdf"),
  docx("docx"),
  doc("doc"),
  png("png"),
  jpeg("jpeg"),
  jpg("jpg"),
  srt("srt"),
  txt("txt"),
  others("others"),
  apk("apk");

  final String type;
  const ImpulseFileType(this.type);
}

enum FileStorageType {
  Internal("Phone Storage"),
  External("Sd card");

  const FileStorageType(this.label);
  final String label;
}

extension FileType on String {
  ImpulseFileType get getFileType {
    final surffix = split(".").last;
    final list =
        ImpulseFileType.values.where((element) => element.type == surffix);
    if (list.isNotEmpty) {
      return list.first;
    } else {
      return ImpulseFileType.others;
    }
  }
}
