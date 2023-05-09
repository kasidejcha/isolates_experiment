import 'dart:isolate';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: BodyWidget(),
      ),
    );
  }
}

class BodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          ElevatedButton(
            child: const Text('start'),
            onPressed: () async {
              // final sum = computationallyExpensiveTask_singleThread(1000000000);
              // print(sum);

              // //ReceivePort is to listen for the isolate to finish job
              // final receivePort = ReceivePort();
              // // here we are passing method name and sendPort instance from ReceivePort as listener
              // await Isolate.spawn(
              //     computationallyExpensiveTask, receivePort.sendPort);

              // //It will listen for isolate function to finish
              // receivePort.listen((sum) {
              //   print(sum);
              // });

              // without using listen
              final receivePort = ReceivePort();
              await Isolate.spawn<SendPort>(
                computationallyExpensiveTask, receivePort.sendPort
              );
              final response = await receivePort.first;
              print("$response");
            },
          )
        ],
      ),
    );
  }
}

// this function should be either top level(outside class) or static method
void computationallyExpensiveTask(SendPort sendPort) {
  print('heavy work started');
  var sum = 0;
  for (var i = 0; i <= 1000000000; i++) {
    sum += i;
  }
  print('heavy work finished');
  //Remember there is no return, we are sending sum to listener defined defore.
  sendPort.send(sum);
}

int computationallyExpensiveTask_singleThread(int value) {
  var sum = 0;
  for (var i = 0; i <= value; i++) {
    sum += i;
  }
  print('finished task');
  return sum;
}