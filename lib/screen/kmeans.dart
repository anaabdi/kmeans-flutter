import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_kmeans/const.dart';
import 'package:flutter_kmeans/model/kmeans.dart';
import 'package:http/http.dart' as http;

class KMeansScreen extends StatefulWidget {
  KMeansScreen({Key? key}) : super(key: key);

  @override
  State<KMeansScreen> createState() => _KMeansScreenState();
}

class _KMeansScreenState extends State<KMeansScreen> {
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
  String? rangeMin;
  String? rangeMax;
  String? result;
  bool isSearching = false;
  final resultController = TextEditingController();

  Map<String, dynamic> results = {};
  Map<String, dynamic> initialCentroids = {};
  int totalCluster = 0;
  int totalIteration = 0;
  String duration = "";

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

  void _submit() {
    final form = formKey.currentState!;

    if (form.validate()) {
      form.save();

      if (kExact == null) {
        _showDialog("Harap masukkan data yang dibutuhkan");
      } else {
        setState(() {
          totalCluster = 0;
          totalIteration = 0;
          duration = "";
          isSearching = true;
        });

        sendData();
      }
    }
  }

  sendData() async {
    var statusCode = 0;

    Uri url = Uri.parse("http://localhost:3080/kmeans");

    var requestBody = {
      "k_exact": kExact!,
    };

    final res = await http.post(url, headers: null, body: requestBody);
    print('res.statusCode: ${res.statusCode}');
    var decodedJson = jsonDecode(res.body);
    print('result: $decodedJson');
    statusCode = res.statusCode;

    var resp = KMeansResponse.fromJson(decodedJson);
    statusCode = res.statusCode;
    print('statusCode $statusCode');
    if (statusCode == 200) {
      result = resp.results.toString();

      results = resp.results!;
      totalCluster = resp.totalCluster!;
      totalIteration = resp.totalIteration!;
      duration = resp.duration!;
      initialCentroids = resp.initialCentroids!;
    } else {
      result = "Gagal mendapatkan hasil";
      print('failed to add result');
    }

    setState(() {
      isSearching = false;
      resultController.text = result!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("K-Means"),
      ),
      body: Center(
        child: Container(
          height: 500,
          width: 500,
          alignment: Alignment.center,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
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
                SizedBox(
                  height: 30,
                ),
                // TextFormField(
                //   decoration: getInputDecoration(
                //     "K Range Max",
                //     "Masukkan K Maximum",
                //     null,
                //   ),
                //   maxLines: 1,
                //   validator: (val) =>
                //       val!.length < 1 ? 'minimal 1 angka' : null,
                //   onSaved: (val) => rangeMax = val,
                //   obscureText: false,
                //   keyboardType: TextInputType.number,
                // ),
                // SizedBox(
                //   height: 30,
                // ),
                ElevatedButton(
                  onPressed: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => KMeansScreen()));
                    _submit();
                  },
                  child: const Text("Calculate"),
                ),
                SizedBox(
                  height: 50,
                ),
                Text("Total Cluster: $totalCluster"),
                SizedBox(
                  height: 20,
                ),
                Text("Total Iteration: $totalIteration"),
                SizedBox(
                  height: 20,
                ),
                Text("Duration: $duration"),
                SizedBox(
                  height: 20,
                ),
                Text("Centroid Awal: $initialCentroids"),
                SizedBox(
                  height: 20,
                ),
                (isSearching)
                    ? const CircularProgressIndicator()
                    : Expanded(
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: const <DataColumn>[
                              DataColumn(
                                label: Text('Cluster'),
                              ),
                              DataColumn(
                                label: Text('Data IDs'),
                              ),
                            ],
                            rows: results.entries
                                .map(
                                  (entry) => DataRow(
                                    cells: [
                                      DataCell(Text(entry.key)),
                                      DataCell(Wrap(
                                        children: [
                                          Text(entry.value),
                                        ],
                                      )),
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
        ),
      ),
    );
  }
}
