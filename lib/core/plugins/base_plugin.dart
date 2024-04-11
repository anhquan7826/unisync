import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

import '../device.dart';

abstract class UnisyncPlugin {
  UnisyncPlugin(this.device, {required this.type});

  final Device device;
  final String type;

  bool isClosed = false;
  final notifier = BehaviorSubject<Map<String, dynamic>>();

  void send(Map<String, dynamic> data, [Uint8List? payload]) {
    device.sendMessage(
      DeviceMessage(
        time: DateTime.now().millisecondsSinceEpoch,
        type: type,
        body: data,
      ),
      payload,
    );
  }

  void onReceive(Map<String, dynamic> data, DeviceMessagePayload? payload);

  @mustCallSuper
  void dispose() {
    notifier.close();
    isClosed = true;
  }
}
