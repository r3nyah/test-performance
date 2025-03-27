import 'dart:io';
import 'package:flutter/material.dart';

Future<void> saveCsv(String csvData, BuildContext context) async {
  final directory = Directory('/storage/emulated/0/Download');
  final filePath = '${directory.path}/performance_log.csv';
  final file = File(filePath);

  await file.writeAsString(csvData);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("CSV saved at: $filePath")),
  );
}
