import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/device_connection.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:uuid/uuid.dart';

abstract class UnisyncPlugin {
  UnisyncPlugin(this.device, {required this.type});

  final Device device;
  final String type;

  bool isClosed = false;
  final notifier = BehaviorSubject<Map<String, dynamic>>();

  final _messages =
      PublishSubject<({Map<String, dynamic> data, Payload? payload})>();

  late final messages = _messages.stream.asBroadcastStream();

  final Map<String, Completer> _completers = {};

  String completer<T>() {
    final uuid = const Uuid().v1();
    _completers[uuid] = Completer<T>();
    return uuid;
  }

  void complete<T>(String id, {required T value}) {
    _completers[id]!.complete(value);
  }

  void completeError(String id,
      {required Object error, StackTrace? stackTrace}) {
    _completers[id]!.completeError(error, stackTrace);
  }

  Future<T> future<T>(String id) {
    return (_completers[id]! as Completer<T>).future;
  }

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

  @mustCallSuper
  void onReceive(Map<String, dynamic> data, Payload? payload) {
    _messages.add((
      data: data,
      payload: payload,
    ));
  }

  @mustCallSuper
  void dispose() {
    notifier.close();
    _messages.close();
    isClosed = true;
  }
}
