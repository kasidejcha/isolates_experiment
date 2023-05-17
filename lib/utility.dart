import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';


// OLD - only works with dart
class JsonFileReader {
  final String basePath;

  JsonFileReader(this.basePath);

  Map<dynamic, dynamic> readJsonFileWeightedGraph(String filePath) {
    var input = File(basePath + filePath).readAsStringSync();
    var map = jsonDecode(input);
    return Map<dynamic, dynamic>.from(map);
  }

  Map<String, dynamic> readJsonFileEdgesGraph(String filePath) {
    var input = File(basePath + filePath).readAsStringSync();
    var map = jsonDecode(input);
    return Map<String, dynamic>.from(map);
  }
}

Future<List<List<dynamic>>> loadData() async {
  final file = await rootBundle.loadString('assets/link_data.json');
  final data = jsonDecode(file);
  return List<List<dynamic>>.from(data.map((list) => List<dynamic>.from(list)));
}

// NEW - works with Flutter
class JsonReader {
  final String basePath;
  JsonReader(this.basePath);

  Future<Map<dynamic, Map<dynamic, dynamic>>> readJsonFileWeightedGraph(String filePath) async {
    final String input = await rootBundle.loadString(basePath + filePath);
    var map = jsonDecode(input);
    return Map<dynamic, Map<dynamic, dynamic>>.from(map);
  }

  Future<Map<String, dynamic>> readJsonFileEdgesGraph(String filePath) async {
    final String input = await rootBundle.loadString(basePath + filePath);
    var map = jsonDecode(input);
    return Map<String, dynamic>.from(map);
  }
}

Map<String, dynamic> findAllEdges(edgeGraph, path, target) {
  Map<String, Map<String, dynamic>> tmpGraph = {for (var key in path) key: edgeGraph[key]};
  Map<String, Map<String, dynamic>> pathGraph = {};
  for (int i = 0; i < tmpGraph.length; i++) {
    var key = tmpGraph.keys.toList()[i];
    pathGraph[key] = {};
    if (key == target) {
      break;
    } else {
      for (var k in tmpGraph[key]!.keys.toList()) {
        if (path.sublist(i).contains(k)) {
          pathGraph[key]![k] = tmpGraph[key]![k];
        }
      }
    }
  }
  return pathGraph;
}

// Map<String, String> noExchangeFn(pathGraph, source, path) {
//   List<List<String>> routes = [];
//   List<List<String>> directions = [];
//   for (var p in path) {
//     for (var i in pathGraph[p].values) {
//       List<String> route = [];
//       List<String> direction = [];
//       for (var j in i.values) {
//         route.add(j['route']);
//         direction.add(j['direction']);
//       }
//       routes.add(route);
//       directions.add(direction);
//     }
//   }
//   // Route
//   Set<dynamic> routeIntersection = Set.of(routes.first);
//   for (List<dynamic> route in routes.sublist(1)) {
//     routeIntersection = routeIntersection.intersection(Set.of(route));
//   }
//   List<dynamic> oneRoute = routeIntersection.toList();

//   // Direction
//   Set<dynamic> directionIntersection = Set.of(directions.first);
//   for (List<dynamic> direction in directions.sublist(1)) {
//     directionIntersection = directionIntersection.intersection(Set.of(direction));
//   }
//   List<dynamic> oneDirection = directionIntersection.toList();
//   return {
//     'route': oneRoute[0],
//     'direction': oneDirection[0]
//   };
// }



// Future<List<List<dynamic>>> importData(queryData) async {
//   var connection = PostgreSQLConnection("192.168.14.91", 5432, "eta", username: "admin", password: "admin");

//   await connection.open();
//   print('Connected to postgresql database');

//   var linkData = await connection.query('select * from $queryData;');
//   await connection.close();
//   return linkData;
// }

void main() {
  final jsonReader = JsonFileReader('data/');
  // final jsonReader = JsonReader('data/');
  var edgeGraph = jsonReader.readJsonFileEdgesGraph('tsb_graph.json');

  // List path = ['1304', '2912', '1305', '1306', '1307'];
  List path = ['1304', '2912', '1305', '1306'];
  String target = path.last;
  String source = path.first;
  Map<String, dynamic> pathGraph = findAllEdges(edgeGraph, path, target);
  print(pathGraph);
}