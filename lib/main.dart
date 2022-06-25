import 'package:flutter/material.dart';
import 'package:flutter_kmeans/const.dart';
import 'package:flutter_kmeans/screen/clastering.dart';
import 'package:flutter_kmeans/screen/kmeans.dart';
import 'package:flutter_kmeans/screen/kmedoids.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter KMEANS KMEDOIDS',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Pencarian KMeans dan KMedoids'),
      //home: ClusteringScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  bool isDataSetReady = false;

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text("Final Project"),
          content: const Text("Author: Arya"),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                //Navigator.pop(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  PlatformFile? objFile;

  void chooseFileUsingFilePicker() async {
    var result = await FilePicker.platform.pickFiles(
      withReadStream:
          true, // this will return PlatformFile object with read stream
    );
    if (result != null) {
      objFile = result.files.single;
      uploadSelectedFile();
      setState(() {
        isDataSetReady = true;
      });
    }
  }

  void uploadSelectedFile() async {
    if (objFile != null) {
//---Create http package multipart request object
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseURL/upload-dataset"),
      );
      //-----add other fields if needed
      //request.fields["id"] = "abc";

      //-----add selected file with request
      request.files.add(http.MultipartFile(
          "datasetFile", objFile!.readStream!, objFile!.size,
          filename: objFile!.name));

      //-------Send request
      var resp = await request.send();

      //------Read response
      String result = await resp.stream.bytesToString();

      //-------Your response
      print(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Text(
            //   'Pilih metode nya:',
            // ),
            // const SizedBox(
            //   height: 30,
            // ),
            // SizedBox(
            //   width: 200,
            //   height: 50,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(context,
            //           MaterialPageRoute(builder: (context) => KMeansScreen()));
            //     },
            //     child: const Text("K-Means"),
            //   ),
            // ),
            // const SizedBox(
            //   height: 30,
            // ),
            // SizedBox(
            //   width: 200,
            //   height: 50,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => KMedoidsScreen()));
            //     },
            //     child: const Text("K-Medoids"),
            //   ),
            // ),

            (objFile != null)
                ? Text("File name : ${objFile!.name}")
                : const SizedBox.shrink(),
            (objFile != null)
                ? Text("File size : ${objFile!.size} bytes")
                : const SizedBox.shrink(),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  chooseFileUsingFilePicker();
                },
                child: const Text("Pilih Dataset"),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: (isDataSetReady)
                    ? () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ClusteringScreen()));
                      }
                    : null,
                child: (isDataSetReady)
                    ? const Text("Mulai Pengelompokan")
                    : const CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        tooltip: 'Info',
        child: const Icon(Icons.question_mark),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
