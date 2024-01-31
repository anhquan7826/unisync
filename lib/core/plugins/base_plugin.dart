import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unisync/core/device_connection.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

abstract class UnisyncPlugin {
  UnisyncPlugin(this.emitter);

  final ConnectionEmitter emitter;
  bool isClosed = false;
  final notifier = BehaviorSubject<Map<String, dynamic>>();

  bool isPluginMessage(DeviceMessage message);

  void onMessageReceived(DeviceMessage message);

  @mustCallSuper
  void dispose() {
    notifier.close();
    isClosed = true;
  }
}
