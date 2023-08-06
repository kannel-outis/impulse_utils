import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:impulse_utils/impulse_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FileManager.instance.getRootPaths(true);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _impulseUtilsPlugin = ImpulseUtils();

  final String path =
      "storage/emulated/0/DCIM/Camera/IMG_20230625_184235_553.jpg";
  final String path2 =
      "storage/emulated/0/Download/Pipe/Clean Architecture with Flutter.mp4";

  final String path3 = "storage/emulated/0/Video/video.mp4";

  late final Future<List<Application>> future;
  late final Future<(String?, Uint8List?)> future2;
  late final List<ImpulseFileEntity> queriedFiles;

  @override
  void initState() {
    super.initState();
    // future = _impulseUtilsPlugin.getInstalledApplication();
    // queriedFiles = FileManager.instance.getFileInDir();
    // future2 = getThumb();
    // initPlatformState();
    // _impulseUtilsPlugin
    //     .getStorageInfo(FileManager.instance.rootPath.first)
    //     .then((value) {
    //   log("${value?.remainingSizeToFileSize.gigaBytes.toString()}");
    // });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformState() async {
  //   await _impulseUtilsPlugin.getInstalledApplication();
  //   return;
  //   String platformVersion;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   // We also handle the message potentially returning null.
  //   try {
  //     platformVersion = await _impulseUtilsPlugin.getPlatformVersion() ??
  //         'Unknown platform version';
  //   } on PlatformException {
  //     platformVersion = 'Failed to get platform version.';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });
  // }

  Future<(String?, Uint8List?)> getThumb() async {
    return await _impulseUtilsPlugin.getMediaThumbNail(
      file: path2,
      isVideo: true,
      returnPath: true,
      size: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    print(FileManager.instance.rootPath);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 50.0),
          // child: ListView.builder(
          //   itemCount: queriedFiles.length,
          //   itemBuilder: (context, index) {
          //     final file = queriedFiles[index];
          //     return ListTile(
          //       title: Text(file.name),
          //       // subtitle:
          //       //     file.fileType == null && file.isFolder ? null : Text(file.fileType!.type),
          //       subtitle:
          //           file.isFolder ? null : Text(file.castToFile.sizeToString),
          //       leading: file.isFolder ? const Icon(Icons.folder) : null,
          //       onTap: () {
          //         if (!file.isFolder) return;
          //         final files = FileManager.instance.getFileInDir(file);
          //         Navigator.of(context).push(
          //           MaterialPageRoute(
          //             builder: (context) => SecondPage(files: files),
          //           ),
          //         );
          //       },
          //     );
          //   },
          // ),
          // child: FutureBuilder(
          //   future: future2,
          //   builder: (context, data) {
          //     if (!data.hasData) return const CircularProgressIndicator();
          //     // return ListView.builder(
          //     //   itemCount: data.data!.length,
          //     //   itemBuilder: (context, index) {
          //     //     final app = data.data![index];
          //     //     return ListTile(
          //     //       leading: Image.memory(app.appIcon),
          //     //       title: Text(app.appName),
          //     //       subtitle: Text(app.isSystemApp.toString()),
          //     //     );
          //     //   },
          //     // );
          //     if (data.data?.$1 == null) {
          //       return Image.memory(data.data!.$2!);
          //     }
          //     return Image.file(File(data.data!.$1!));
          //   },
          // ),
          // child: MediaThumbnail(
          //   placeHolder: const Icon(
          //     Icons.video_label,
          //     size: 40,
          //   ),
          //   file: path3,
          //   isVideo: true,
          //   // size: const Size(150, 150),
          //   reCache: true,
          // ),
          child: FutureBuilder(
            future: FileManager.instance.getFileInDirAsync(),
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                return const CircularProgressIndicator();
              } else {
                log((snapshot.data!.first as ImpulseFileStorage)
                    .usedSizeToFileSize
                    .sizeToString);
                log((snapshot.data!.last as ImpulseFileStorage)
                    .usedSizeToFileSize
                    .sizeToString);
                return ListView(
                  children: [
                    // ...snapshot.data!.map(
                    //   (e) => Text(e.fileSystemEntity.path),
                    // ),
                    for (final s in snapshot.data!)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.isRoot
                              ? (s as ImpulseFileStorage).type.label
                              : s.name),
                          Text(s.isRoot.toString()),
                        ],
                      ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
