enum ImpulseFileType {
  mp3("Mp3"),
  mp4("Mp4"),
  mov("Mov"),
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

extension FileType on String {
  ImpulseFileType get getFileType {
    final surffix = split(".").last;
    return ImpulseFileType.values
        .where((element) => element.type == surffix)
        .first;
  }
}
