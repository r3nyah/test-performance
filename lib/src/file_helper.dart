import 'dart:io';
import 'dart:html' as html;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'performance_monitor.dart';

class FileHelper {
  static String generateCsvData(List<PerformanceResult> logs) {
    if (logs.isEmpty) return "No data recorded.";

    StringBuffer csvBuffer = StringBuffer();
    csvBuffer.writeln("Performance Data Log:\n");

    for (var log in logs) {
      csvBuffer.writeln(log.toCsvString());
    }

    // Calculate mean values
    double meanCpu = logs.map((e) => e.cpuUsage).reduce((a, b) => a + b) / logs.length;
    double meanRam = logs.map((e) => e.ramUsage).reduce((a, b) => a + b) / logs.length;
    double meanExecution = logs.map((e) => e.executionTime).reduce((a, b) => a + b) / logs.length;

    csvBuffer.writeln("\n===== MEAN VALUES =====");
    csvBuffer.writeln("Mean CPU Usage: ${meanCpu.toStringAsFixed(2)}%");
    csvBuffer.writeln("Mean RAM Usage: ${meanRam.toStringAsFixed(2)} MB");
    csvBuffer.writeln("Mean Execution Time: ${meanExecution.toStringAsFixed(2)}s");

    return csvBuffer.toString();
  }

  static void downloadCsv(List<PerformanceResult> logs) {
    final String csvContent = generateCsvData(logs);
    final blob = html.Blob([csvContent]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "performance_data.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
