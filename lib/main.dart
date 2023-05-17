import 'dart:async';
import 'dart:isolate';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

List item = [1,2,3,4];

void main() {
  WidgetsFlutterBinding.ensureInitialized(); 
  GetStorage.init();
  GetStorage().erase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: BodyWidget(),
      ),
    );
  }
}



class BodyWidget extends StatefulWidget {
  const BodyWidget({super.key});

  @override
  State<BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  

  @override
  Widget build(BuildContext context) {

    ReceivePort cacheReceivePort = ReceivePort();
    ReceivePort cacheReceiveResponsePort = ReceivePort();
    Isolate.spawn<List<SendPort>>(cacheIsolateEntry, [cacheReceivePort.sendPort, cacheReceiveResponsePort.sendPort]);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          ElevatedButton(
            child: const Text('start'),
            onPressed: () async {
              SendPort cacheSendPort = await cacheReceivePort.first;
              cacheSendPort.send({
                'action': 'get',
                'key': 'helloworld_data',
              });
              cacheReceiveResponsePort.listen((message){
                print("Message: $message");
                if (message == null){
                  cacheSendPort.send({
                    'action': 'set',
                    'key': 'helloworld_data',
                    'value': [1,2,3,4],
                  });
                }
                Timer(const Duration(seconds: 3), () {
                  print("3 seconds Delay");
                  cacheSendPort.send({
                    'action': 'compute',
                    'key': 'helloworld_data',
                  });
                });
              });
            },
          )
        ],
      ),
    );
  }
}

void cacheIsolateEntry(List<SendPort> listSendPort) async {
  ReceivePort receivePort = ReceivePort();
  listSendPort[0].send(receivePort.sendPort);
  Map cacheData = {};

  receivePort.listen((message) async{
    if (message == 'stop') {
      receivePort.close();
      return;
    }

    
    String action = message['action'];
    String key = message['key'];
    var value = message['value'];

    if (action == 'get') {
      var data = cacheData[key];
      listSendPort[1].send(data);

    } else if (action == 'compute'){
      var output = cacheData[key][3]*10;
      listSendPort[1].send(output);

    } else if (action == 'set') {
      var tmp = {
        key:value
      };
      print('Setting Message');
      cacheData.addAll(tmp);
    }
  });
}
