import 'dart:typed_data';

import 'package:impulse_utils/src/models/file_size.dart';

class Application extends FileSize {
  final String appName;
  final String packageName;
  final String appPath;
  final Uint8List appIcon;
  final int appSize;
  final bool isSystemApp;
  final bool isDisabled;

  Application({
    required this.appName,
    required this.packageName,
    required this.appPath,
    required this.appIcon,
    required this.appSize,
    this.isSystemApp = false,
    this.isDisabled = false,
  }) : super(appSize);
  factory Application.fromMap(Map<String, dynamic> map) {
    return Application(
      appName: map["appName"] as String,
      packageName: map["packageName"] as String,
      appPath: map["appPath"] as String,
      appIcon: Uint8List.fromList(List<int>.from(map["appIcon"])),
      appSize: map["appSize"] as int,
      isSystemApp: map["isSystemApp"] as bool,
      isDisabled: map["isDisabled"] as bool,
    );
  }
}
