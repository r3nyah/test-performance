import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Import file yang sesuai berdasarkan platform
import 'utils/download_log.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _timer;
  List<String> logData = [];

  @override
  void initState() {
    super.initState();
    startMonitoring();
  }

  void startMonitoring() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        int cpuUsage = (50 + (50 * (timer.tick % 5))).toInt();
        int ramUsage = (400 + (100 * (timer.tick % 5))).toInt();
        int runtime = timer.tick * 2;

        logData.add("$runtime\t$cpuUsage\t$ramUsage");
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> downloadLog(BuildContext context) async {
    _timer?.cancel();

    // Header CSV
    String csvData = "Time(ms),CPU(%),RAM(MB)\n";

    // Konversi data ke format CSV yang benar
    for (String entry in logData) {
      List<String> values = entry.split("\t");
      if (values.length == 3) {
        int timeMs = int.parse(values[0]) * 1000; // Konversi detik ke milidetik
        csvData += "$timeMs,${values[1]},${values[2]}\n";
      }
    }

    await saveCsv(csvData, context);
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Performance Monitor")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Monitoring..."),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => downloadLog(context),
                child: Text("Download CSV Log"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
