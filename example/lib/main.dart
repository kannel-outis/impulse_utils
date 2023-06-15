import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:impulse_utils/file_manager/file_manager.dart';
import 'package:impulse_utils/file_manager/impulse_file.dart';
import 'package:impulse_utils/impulse_utils.dart';
import 'package:impulse_utils/models/application.dart';
import 'package:impulse_utils_example/second_page.dart';

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

  late final Future<List<Application>> future;
  late final List<ImpulseFileEntity> queriedFiles;

  @override
  void initState() {
    super.initState();
    future = _impulseUtilsPlugin.getInstalledApplication();
    queriedFiles = FileManager.instance.getFileInDir();
    // initPlatformState();
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
          child: ListView.builder(
            itemCount: queriedFiles.length,
            itemBuilder: (context, index) {
              final file = queriedFiles[index];
              return ListTile(
                title: Text(file.name),
                // subtitle:
                //     file.fileType == null && file.isFolder ? null : Text(file.fileType!.type),
                subtitle:
                    file.isFolder ? null : Text(file.castToFile.sizeToString),
                leading: file.isFolder ? const Icon(Icons.folder) : null,
                onTap: () {
                  if (!file.isFolder) return;
                  final files = FileManager.instance.getFileInDir(file);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SecondPage(files: files),
                    ),
                  );
                },
              );
            },
          ),
          // child: FutureBuilder(
          //   future: future,
          //   builder: (context, data) {
          //     if (!data.hasData) return const CircularProgressIndicator();
          //     return ListView.builder(
          //       itemCount: data.data!.length,
          //       itemBuilder: (context, index) {
          //         final app = data.data![index];
          //         return ListTile(
          //           leading: Image.memory(app.appIcon),
          //           title: Text(app.appName),
          //           subtitle: Text(app.isSystemApp.toString()),
          //         );
          //       },
          //     );
          //   },
          // ),
        ),
      ),
    );
  }
}
