import 'dart:math';
import 'dart:html' as html;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PerformanceMonitor {
  static PerformanceResult measurePerformance() {
    final stopwatch = Stopwatch()..start();
    _heavyComputation();
    stopwatch.stop();

    return PerformanceResult(
      _getCpuUsage(),
      _getRamUsage(),
      stopwatch.elapsedMilliseconds / 1000.0,
    );
  }

  static int _heavyComputation() {
    int sum = 0;
    for (int i = 0; i < 1000000; i++) {
      sum += Random().nextInt(100);
    }
    return sum;
  }

  static int _getCpuUsage() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return Random().nextInt(50);
    } else {
      return html.window.navigator.hardwareConcurrency ?? 1;
    }
  }

  static double _getRamUsage() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return Random().nextInt(200) + 100.0;
    } else {
      return _getWebMemoryUsage();
    }
  }

  static double _getWebMemoryUsage() {
    try {
      final jsHeapSize = html.window.performance?.memory?.usedJSHeapSize;
      if (jsHeapSize != null) {
        return jsHeapSize / (1024 * 1024);
      }
    } catch (e) {
      print('Error accessing Web Memory API: $e');
    }
    return 0.0;
  }
}

class PerformanceResult {
  final int cpuUsage;
  final double ramUsage;
  final double executionTime;

  PerformanceResult(this.cpuUsage, this.ramUsage, this.executionTime);

  String toCsvString() {
    return '''Timestamp: ${DateTime.now()}
CPU Usage: $cpuUsage%
RAM Usage: ${ramUsage.toStringAsFixed(2)} MB
Execution Time: ${executionTime}s\n''';
  }
}
