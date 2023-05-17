import 'dart:convert';
import 'dart:io';

Future<List<dynamic>> readJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  return map;
}

void main () async {
  // List minPath = [2070, 2071, 2072, 2073, 2074, 2075, 2076, 2077, 
  //                 2078, 2079, 2080, 2081, 2082, 2083, 2084, 2085, 2086, 2087, 2088, 
  //                 2089, 2090, 2091, 2092, 2093, 2094, 2095, 2096, 2097, 2098, 2099, 
  //                 2100, 2101, 2102, 2103, 2104, 2105, 2106, 2069, 1996, 1997, 1998, 
  //                 1999, 1994, 1995, 1975, 1976, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 
  //                 92, 93, 94, 1977, 410, 411, 412, 413, 414, 3031, 3032, 3033, 3034, 3035, 
  //                 3036, 4586, 3037, 3038, 3039, 3040, 3041, 3042, 3043, 3044, 3045, 3046, 3666, 
  //                 3667, 3668, 3669, 3360, 3361, 4179, 2967, 2968, 4180, 4110, 2924, 2925, 3340, 
  //                 3641, 3642, 3643, 3644, 3002, 3645, 3004, 3005, 3006, 3007, 3009];
  List<int> minPath = [2070, 2071, 2072, 2073];
  // var map = {};
  // for (var i = 0; i < minPath.length - 1; i++) {
  //   map[minPath[i].toString()] = {minPath[i+1].toString(): {}};
  // }
  int target = minPath.last;
  // List start = minPath.sublist(0,minPath.length-1);
  // List end = minPath.sublist(1,minPath.length);
  var linkData = await readJsonFile('assets/eta_link_data.json');


  // Map<String, Map<String, dynamic>> pathGraph = {};
  // for (int i = 0; i < minPath.length; i++){
  //   pathGraph[minPath[i].toString()] = {};
  //   if (minPath[i]==target){
  //     break;
  //   } else {
  //   var data = etaLinkData.where((element) {
  //     var tmp = element[element.length-2] == start[i] && element[element.length-1]== end[i];
  //   return tmp;
  //   }).toList();

  //   for (int j = 0; j < data.length; j++){
  //     map[start[i].toString()][end[i].toString()][j.toString()] = {
  //           "route": data[j][1],
  //           "direction": data[j][2],
  //           "st_num": "${data[j][3]}_${data[j][4]}"
  //         };
  //     }};
  //   }
  // print(map);
  Map output = findAllEdges(linkData, minPath, target);
  print(output);
}

Map<String, dynamic> findAllEdges(List<dynamic>linkData, List<int> minPath, int target) {
  Map<String, dynamic> edgeGraph = {};
  for (var i = 0; i < minPath.length - 1; i++) {
    edgeGraph[minPath[i].toString()] = {minPath[i+1].toString(): {}};
  } // initialize edgeGraph
  List start = minPath.sublist(0,minPath.length-1);
  List end = minPath.sublist(1,minPath.length);
  // print(start);

  Map<String, Map<String, dynamic>> pathGraph = {};
  for (int i = 0; i < minPath.length; i++){
    pathGraph[minPath[i].toString()] = {};
    if (minPath[i]==target){
      break;
    } else {
    var data = linkData.where((element) {
      var tmp = element[element.length-2] == start[i] && element[element.length-1]== end[i];
    return tmp;
    }).toList();
    for (int j = 0; j < data.length; j++){
      edgeGraph[start[i].toString()][end[i].toString()][j.toString()] = {
            "route": data[j][1],
            "direction": data[j][2],
            "st_num": "${data[j][3]}_${data[j][4]}"
          };
      }}
    }
  return edgeGraph;
}