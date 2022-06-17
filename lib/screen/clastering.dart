import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_kmeans/const.dart';
import 'package:flutter_kmeans/model/dataset.dart';
import 'package:flutter_kmeans/model/kmeans.dart';
import 'package:http/http.dart' as http;

class ClusteringScreen extends StatefulWidget {
  ClusteringScreen({Key? key}) : super(key: key);

  @override
  State<ClusteringScreen> createState() => _ClusteringScreenState();
}

class _ClusteringScreenState extends State<ClusteringScreen> {
  InputDecoration getInputDecoration(
      String labelText, String hintText, Widget? suffixIcon) {
    return InputDecoration(
      suffixIcon: suffixIcon,
      focusColor: secondaryColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: secondaryTextColor,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: secondaryTextColor,
          width: 1,
        ),
      ),
      labelText: labelText,
      labelStyle:
          TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w400),
      hintText: hintText,
      hintStyle: TextStyle(
          color: secondaryTextColor, fontSize: 14, fontWeight: FontWeight.w400),
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: secondaryTextColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  String? kExact;
  String? initialCentroidRowIDs;
  String? rangeMin;
  String? rangeMax;
  String? result;
  bool isSearchingKMeans = false;
  bool isSearchingKMedoids = false;
  final resultController = TextEditingController();

  Map<String, dynamic> resultsKMeans = {};
  Map<String, dynamic> initialCentroidsKMeans = {};
  int totalClusterKMeans = 0;
  int totalIterationKMeans = 0;
  String durationKMeans = "";

  Map<String, dynamic> resultsKMedoids = {};
  Map<String, dynamic> initialCentroidsKMedoids = {};
  int totalClusterKMedoids = 0;
  int totalIterationKMedoids = 0;
  String durationKMedoids = "";

  List<Datasets>? datasets = [];

  final formKey = new GlobalKey<FormState>();

  void _showDialog(String message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text("Opss"),
          content: Text(message),
          actions: <Widget>[
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDatasets();
  }

  void _submitKMeans() {
    final form = formKey.currentState!;

    if (form.validate()) {
      form.save();

      if (kExact == null || initialCentroidRowIDs == null) {
        _showDialog("Harap masukkan data yang dibutuhkan");
      } else {
        setState(() {
          totalClusterKMeans = 0;
          totalIterationKMeans = 0;
          durationKMeans = "";
          initialCentroidsKMeans = {};
          resultsKMeans = {};
          isSearchingKMeans = true;
        });

        sendDataMeans();
      }
    }
  }

  void _submitKMedoids() {
    final form = formKey.currentState!;

    if (form.validate()) {
      form.save();

      if (kExact == null || initialCentroidRowIDs == null) {
        _showDialog("Harap masukkan data yang dibutuhkan");
      } else {
        setState(() {
          totalClusterKMedoids = 0;
          totalIterationKMedoids = 0;
          durationKMedoids = "";
          initialCentroidsKMedoids = {};
          resultsKMedoids = {};
          isSearchingKMedoids = true;
        });

        sendDataMedoids();
      }
    }
  }

  void showSnackBar(String pesan, Color color) {
    final snackbar = SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(
        pesan,
        textAlign: TextAlign.center,
      ),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  sendDataMedoids() async {
    var statusCode = 0;

    Uri url = Uri.parse("$baseURL/kmedoids");

    var requestBody = {
      "k_exact": kExact!,
      "initial_centroid_row_ids": initialCentroidRowIDs!,
    };

    final res = await http.post(url, headers: null, body: requestBody);
    print('res.statusCode: ${res.statusCode}');
    statusCode = res.statusCode;
    if (statusCode != 200) {
      setState(() {
        isSearchingKMedoids = false;
        resultController.text = res.body;
        print('result: ${res.body}');
      });

      showSnackBar(res.body, Colors.redAccent);
      return;
    }

    var decodedJson = jsonDecode(res.body);
    print('result: $decodedJson');

    var resp = KMeansResponse.fromJson(decodedJson);
    print('statusCode $statusCode');
    if (statusCode == 200) {
      result = resp.results.toString();

      resultsKMedoids = resp.results!;
      totalClusterKMedoids = resp.totalCluster!;
      totalIterationKMedoids = resp.totalIteration!;
      durationKMedoids = resp.duration!;
      initialCentroidsKMedoids = resp.initialCentroids!;
    } else {
      result = "Gagal mendapatkan hasil";
      print('failed to add result');
    }

    setState(() {
      isSearchingKMedoids = false;
      resultController.text = result!;
    });
  }

  sendDataMeans() async {
    var statusCode = 0;

    Uri url = Uri.parse("$baseURL/kmeans");

    var requestBody = {
      "k_exact": kExact!,
      "initial_centroid_row_ids": initialCentroidRowIDs!,
    };

    final res = await http.post(url, headers: null, body: requestBody);
    print('res.statusCode: ${res.statusCode}');
    statusCode = res.statusCode;
    if (statusCode != 200) {
      setState(() {
        isSearchingKMeans = false;
        resultController.text = res.body;
        print('result: ${res.body}');
      });

      showSnackBar(res.body, Colors.redAccent);
      return;
    }

    var decodedJson = jsonDecode(res.body);
    print('result: $decodedJson');

    var resp = KMeansResponse.fromJson(decodedJson);
    print('statusCode $statusCode');
    if (statusCode == 200) {
      result = resp.results.toString();

      resultsKMeans = resp.results!;
      totalClusterKMeans = resp.totalCluster!;
      totalIterationKMeans = resp.totalIteration!;
      durationKMeans = resp.duration!;
      initialCentroidsKMeans = resp.initialCentroids!;
    } else {
      result = "Gagal mendapatkan hasil";
      print('failed to add result');
    }

    setState(() {
      isSearchingKMeans = false;
      resultController.text = result!;
    });
  }

  getDatasets() async {
    var statusCode = 0;

    Uri url = Uri.parse("$baseURL/datasets");

    final res = await http.get(
      url,
      headers: null,
    );
    print('res.statusCode: ${res.statusCode}');
    statusCode = res.statusCode;
    if (statusCode != 200) {
      setState(() {});

      showSnackBar(res.body, Colors.redAccent);
      return;
    }

    var decodedJson = jsonDecode(res.body);
    print('result: $decodedJson');

    var resp = Dataset.fromJson(decodedJson);
    print('statusCode $statusCode');
    if (statusCode != 200) {
      result = "Gagal mendapatkan dataset";
      print(result);
    } else {
      setState(() {
        datasets = resp.datasets;
      });
      print('len datasets: ${datasets!.length}');
    }
  }

  void displayDatasets() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        List<DataRow> rows = [];
        for (var element in datasets!) {
          rows.add(DataRow(
            cells: [
              DataCell(Text('${element.id}')),
              DataCell(Text('${element.humidity}')),
              DataCell(Text('${element.temperature}')),
              DataCell(Text('${element.stepCount}')),
            ],
          ));
        }

        return AlertDialog(
          title: Text("Dataset"),
          content: Container(
            height: 700,
            width: 500,
            child: SingleChildScrollView(
              child: DataTable(
                dataRowColor:
                    MaterialStateColor.resolveWith((states) => Colors.white),
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'No.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Humidity',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text('Temperature',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Step Count',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
                rows: rows,
              ),
            ),
          ),
        );
        // AlertDialog(
        //   title: const Text("Final Project"),
        //   content: const Text("Author: Arya"),
        //   actions: [
        //     TextButton(
        //       child: const Text("OK"),
        //       onPressed: () {
        //         //Navigator.pop(context);
        //         Navigator.of(context).pop();
        //       },
        //     ),
        //   ],
        // );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: displayDatasets,
        tooltip: 'Display Datasets',
        child: const Icon(Icons.info_outline),
      ),
      appBar: AppBar(
        title: const Text("Clustering"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // INPUTTAN
              Container(
                padding: EdgeInsets.all(50),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                        width: 500,
                        child: TextFormField(
                          decoration: getInputDecoration(
                            "Nilai K",
                            "Masukkan Nilai K / Jumlah Cluster yang diinginkan",
                            null,
                          ),
                          maxLines: 1,
                          validator: (val) =>
                              (int.parse(val!) < 2 || int.parse(val) > 9)
                                  ? 'minimal 2 dan tidak boleh lebih dari 9'
                                  : null,
                          onSaved: (val) => kExact = val,
                          obscureText: false,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: 50,
                        width: 500,
                        child: TextFormField(
                          decoration: getInputDecoration(
                            "Data ID Centroid Awal",
                            "Masukkan Data ID Pilihan Centroid Awal, sejumlah nilai K, dipisah koma ,",
                            null,
                          ),
                          maxLines: 2,
                          validator: (val) => (val!.isEmpty)
                              ? 'minimal 1 karakter, sesuaikan dengan nilai K'
                              : null,
                          onSaved: (val) => initialCentroidRowIDs = val,
                          obscureText: false,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
              // Clustering
              Container(
                height: screenSize.height,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // KMEANS
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Navigator.push(context,
                              //     MaterialPageRoute(builder: (context) => ClusteringScreen()));
                              _submitKMeans();
                            },
                            child: const Text("Run K-Means"),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              Text("Total Cluster: $totalClusterKMeans"),
                              const SizedBox(
                                width: 20,
                              ),
                              Text("Total Iteration: $totalIterationKMeans"),
                              const SizedBox(
                                width: 20,
                              ),
                              Text("Duration: $durationKMeans"),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text("Centroid Awal: $initialCentroidsKMeans"),
                          const SizedBox(
                            height: 20,
                          ),
                          (isSearchingKMeans)
                              ? const CircularProgressIndicator()
                              : Container(
                                  height: 400,
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      dataRowColor:
                                          MaterialStateColor.resolveWith(
                                              (states) => Colors.white),
                                      dataRowHeight: 300,
                                      headingRowHeight: 50.0,
                                      columns: const <DataColumn>[
                                        DataColumn(
                                          label: Text(
                                            'Cluster',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text('Data IDs',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                      rows: resultsKMeans.entries
                                          .map(
                                            (entry) => DataRow(
                                              cells: [
                                                DataCell(Text(entry.key)),
                                                DataCell(
                                                  Wrap(
                                                    children: [
                                                      Text(entry.value),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    // KMEDOIDS
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _submitKMedoids();
                            },
                            child: const Text("Run K-Medoids"),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              Text("Total Cluster: $totalClusterKMedoids"),
                              const SizedBox(
                                width: 20,
                              ),
                              Text("Total Iteration: $totalIterationKMedoids"),
                              const SizedBox(
                                width: 20,
                              ),
                              Text("Duration: $durationKMedoids"),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text("Centroid Awal: $initialCentroidsKMedoids"),
                          const SizedBox(
                            height: 20,
                          ),
                          (isSearchingKMedoids)
                              ? const CircularProgressIndicator()
                              : Container(
                                  height: 400,
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      dataRowColor:
                                          MaterialStateColor.resolveWith(
                                              (states) => Colors.white),
                                      dataRowHeight: 300,
                                      headingRowHeight: 50.0,
                                      columns: const <DataColumn>[
                                        DataColumn(
                                          label: Text(
                                            'Cluster',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text('Data IDs',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                      rows: resultsKMedoids.entries
                                          .map(
                                            (entry) => DataRow(
                                              cells: [
                                                DataCell(Text(entry.key)),
                                                DataCell(
                                                  Wrap(
                                                    children: [
                                                      Text(entry.value),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
