import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unisync/core/device_connection.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

import '../device.dart';

abstract class UnisyncPlugin {
  UnisyncPlugin(this.device, {required this.type});

  final Device device;
  final String type;

  bool isClosed = false;
  final notifier = BehaviorSubject<Map<String, dynamic>>();

  void send(Map<String, dynamic> data) {
    device.sendMessage(DeviceMessage(type: type, body: data));
  }

  void onReceive(Map<String, dynamic> data);

  @mustCallSuper
  void dispose() {
    notifier.close();
    isClosed = true;
  }
}
