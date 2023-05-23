import 'dart:developer';
import 'dart:isolate';

void isolateEntry(SendPort sendPort) {
  ReceivePort receivePort = ReceivePort();
  print('iso');
  // Listen for messages on the receivePort
  receivePort.listen((message) {
    // print('Received message in isolate: $message');
    sendPort.send('Received message in isolate: $message from sendPort');
  });

  // Send the receivePort's sendPort back to the main isolate
  sendPort.send(receivePort.sendPort);
}

Stream createBoardcastStream(ReceivePort receivePort){
  final Stream boardcastStream = receivePort.asBroadcastStream(
    onCancel: (controller) {
      print('Stream paused');
      // controller.pause();
      controller.cancel();
    },
    onListen: (controller) async {
      if (controller.isPaused) {
        print('Stream resumed');
        controller.resume();
      }
    },
  );
  return boardcastStream;
}

void main() async {
  ReceivePort mainReceive = ReceivePort();
  Isolate isolate = await Isolate.spawn(isolateEntry, mainReceive.sendPort);
  Stream mainReceivePort = createBoardcastStream(mainReceive);
  SendPort isolateSendPort = await mainReceivePort.first;

  print('pause: $isolateSendPort');
  Capability resumeCapability = Capability();
  isolate.pause(resumeCapability); // Pause the isolate

  // Send a message to the isolate while it's paused
  isolateSendPort.send('Hello');

  // Some time later...
  print('resume');
  isolate.resume(resumeCapability); // Resume the isolate

  // Send another message to the isolate after resuming
  isolateSendPort.send('World');
  
  var isoOutput1 = await mainReceivePort.first;
  print(isoOutput1);
  var isoOutput2 = await mainReceivePort.first;
  print(isoOutput2);
}
