import 'dart:async';
import 'dart:isolate';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init(); // Initialize the storage

  // Start the cache isolate
  ReceivePort cacheReceivePort = ReceivePort();
  Isolate cacheIsolate = await Isolate.spawn(cacheIsolateEntry, cacheReceivePort.sendPort);
  SendPort cacheSendPort = await cacheReceivePort.first;

  // Store some data in the cache isolate
  cacheSendPort.send({
    'action': 'set',
    'key': 'myDataKey',
    'value': 'https://example.com/image.png',
  });

  // Spawn a new isolate to retrieve the data from the cache isolate and perform computations
  ReceivePort computationResponsePort = ReceivePort();
  Isolate computationIsolate = await Isolate.spawn(computationIsolateEntry, {
    'cacheSendPort': cacheSendPort,
    'key': 'myDataKey',
    'responsePort': computationResponsePort.sendPort,
  });
  SendPort computationSendPort = await computationResponsePort.first;

  // Wait for the computation to complete
  // dynamic computedData = await computationSendPort.first;

  // print(computedData); // Output: "https://example.com/image.png"

  // // Stop the computation and cache isolates
  // computationSendPort.send('stop');
  // await computationIsolate.kill();
  // cacheSendPort.send('stop');
  // await cacheIsolate.kill();
}

void cacheIsolateEntry(SendPort sendPort) async {
  ReceivePort receivePort = ReceivePort();
  // sendPort.send(receivePort.sendPort);

  receivePort.listen((message) async {
    if (message == 'stop') {
      receivePort.close();
      return;
    }

    String action = message['action'];
    String key = message['key'];
    dynamic value = message['value'];

    if (action == 'get') {
      String myData = await GetStorage().read(key);
      sendPort.send(myData);
    } else if (action == 'set') {
      await GetStorage().write(key, value);
    }
  });
}

void computationIsolateEntry(Map<dynamic, dynamic> message) async {
  SendPort cacheSendPort = message['cacheSendPort'];
  String key = message['key'];
  SendPort responsePort = message['responsePort'];

  // Retrieve the data from the cache isolate
  ReceivePort cacheResponsePort = ReceivePort();
  cacheSendPort.send({
    'action': 'request',
    'key': key,
    'value': null,
    'responsePort': cacheResponsePort.sendPort,
  });
  dynamic myData = await cacheResponsePort.first;

  // Perform computations on the retrieved data
  String computedData = myData;

  // Send the computed data back to the main isolate
  responsePort.send(computedData);

  // Listen for stop message
  // await responsePort.first;
}
