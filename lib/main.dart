import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
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
  List<FlSpot> cpuData = [];
  List<FlSpot> ramData = [];
  int loopCount = 1000000;
  List<int> quickSortData = List.generate(10000, (_) => Random().nextInt(10000));

  @override
  void initState() {
    super.initState();
    startMonitoring();
  }

  int fibonacciRecursive(int n) {
    if (n <= 1) return n;
    return fibonacciRecursive(n - 1) + fibonacciRecursive(n - 2);
  }

  void quickSort(List<int> list, int low, int high) {
    if (low < high) {
      int pivotIndex = partition(list, low, high);
      quickSort(list, low, pivotIndex - 1);
      quickSort(list, pivotIndex + 1, high);
    }
  }

  int partition(List<int> list, int low, int high) {
    int pivot = list[high];
    int i = low - 1;
    for (int j = low; j < high; j++) {
      if (list[j] < pivot) {
        i++;
        int temp = list[i];
        list[i] = list[j];
        list[j] = temp;
      }
    }
    int temp = list[i + 1];
    list[i + 1] = list[high];
    list[high] = temp;
    return i + 1;
  }

  void startMonitoring() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        int cpuUsage = (50 + (50 * (timer.tick % 5))).toInt();
        int ramUsage = (400 + (100 * (timer.tick % 5))).toInt();
        int runtime = timer.tick * 2 * 1000;

        fibonacciRecursive(40);
        for (int i = 0; i < loopCount; i++) {}
        quickSort(quickSortData, 0, quickSortData.length - 1);

        logData.add("$runtime,$cpuUsage,$ramUsage");
        cpuData.add(FlSpot(timer.tick.toDouble(), cpuUsage.toDouble()));
        ramData.add(FlSpot(timer.tick.toDouble(), ramUsage.toDouble()));
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

    String csvData = "Time(ms),CPU(%),RAM(MB)\n";
    for (String entry in logData) {
      csvData += "$entry\n";
    }

    await saveCsv(csvData, context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Performance Monitor")),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 150, child: LineChart(LineChartData(lineBarsData: [LineChartBarData(spots: cpuData, isCurved: true, color: Colors.red, dotData: FlDotData(show: false))]))),
            SizedBox(height: 150, child: LineChart(LineChartData(lineBarsData: [LineChartBarData(spots: ramData, isCurved: true, color: Colors.blue, dotData: FlDotData(show: false))]))),
            ElevatedButton(
              onPressed: () => downloadLog(context),
              child: Text("Download CSV Log"),
            ),
          ],
        ),
      ),
    );
  }
}
