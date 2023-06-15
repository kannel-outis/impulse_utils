import 'package:flutter/material.dart';
import 'package:impulse_utils/file_manager/file_manager.dart';
import 'package:impulse_utils/file_manager/impulse_file.dart';

class SecondPage extends StatelessWidget {
  final List<ImpulseFileEntity> files;
  const SecondPage({
    super.key,
    required this.files,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 50.0),
        child: ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
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
    );
  }
}
