import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:isolates/utility.dart';


Future readJson() async {
  var weightedGraph = await rootBundle.loadString('assets/sample.json');
  var map = jsonDecode(weightedGraph);
  return map;
}



void computationallyExpensiveTask(List arguments) async {
  var stopwatchIsolate = arguments[1];
  print('stopwatch_isolate_spawn: ${stopwatchIsolate.elapsedMilliseconds/1000}');
  SendPort sendPort = arguments[0];
  sendPort.send(readJson());
}
