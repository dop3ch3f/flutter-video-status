import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_status/utilities.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whatsapp Status Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Whatsapp Status Demo',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final UtilityMethods _utilityMethods = UtilityMethods();
  bool isImageGotten = false;
  List<String> imagePaths = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      bottomNavigationBar: FlatButton.icon(
        onPressed: () async {
          try {
            File file = await FilePicker.getFile(
              type: FileType.video,
            );
            print("Processing initiated");
            List<String> image_paths =
                await _utilityMethods.generateVideoSnapshots(file);
            print("snapshot generation complete");
            setState(() {
              imagePaths = List.from(image_paths);
              isImageGotten = true;
            });
          } on Exception catch (e) {
            print("An Exception occurred:");
            print(e);
          }
        },
        icon: Icon(Icons.file_upload),
        label: Text("Select Video"),
        color: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: isImageGotten
              ? List.generate(imagePaths.length,
                  (index) => Image.file(File(imagePaths[index])))
              : [],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
