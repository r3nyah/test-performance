import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import './performance_monitor.dart';
import './file_helper.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  _PerformanceScreenState createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  List<PerformanceResult> _performanceLogs = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _measurePerformance();
    });
  }

  Future<void> _measurePerformance() async {
    final result = PerformanceMonitor.measurePerformance();
    setState(() {
      _performanceLogs.add(result);
    });
  }

  void _downloadCsv() {
    FileHelper.downloadCsv(_performanceLogs);
  }

  List<FlSpot> _getCpuData() {
    return _performanceLogs.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.cpuUsage.toDouble())).toList();
  }

  List<FlSpot> _getRamData() {
    return _performanceLogs.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.ramUsage)).toList();
  }

  List<FlSpot> _getExecutionData() {
    return _performanceLogs.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.executionTime)).toList();
  }

  Widget _buildChart(String title, List<FlSpot> data, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey)),
              lineBarsData: [
                LineChartBarData(
                  spots: data,
                  isCurved: true,
                  color: color,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: color.withOpacity(0.2)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 350,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildChart("CPU Usage (%)", _getCpuData(), Colors.red),
                  _buildChart("RAM Usage (MB)", _getRamData(), Colors.blue),
                  _buildChart("Execution Time (s)", _getExecutionData(), Colors.green),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _downloadCsv,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Download CSV'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
