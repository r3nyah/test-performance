import 'dart:html' as html;
import 'package:flutter/material.dart';

Future<void> saveCsv(String csvData, BuildContext context) async {
  final blob = html.Blob([csvData]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "performance_log.csv")
    ..click();
  html.Url.revokeObjectUrl(url);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("CSV file downloaded")),
  );
}
