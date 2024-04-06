import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/logger.dart';
import 'package:unisync/utils/push_notification.dart';

import '../../device.dart';

class NotificationPlugin extends UnisyncPlugin {
  NotificationPlugin(Device device) : super(device, type: DeviceMessage.Type.NOTIFICATION);

  final List<NotificationData> _notifications = [];

  List<NotificationData> get notifications => _notifications.toList();

  @override
  void onReceive(Map<String, dynamic> data, DeviceMessagePayload? payload) {
    _addNotification(NotificationData(
      timestamp: data['timestamp'],
      appName: data['app_name'].toString(),
      title: data['title'].toString(),
      text: data['text'].toString(),
    ));
    PushNotification.showNotification(
      title: '${data['app_name']} • ${data['title']}',
      text: data['text'].toString(),
    );
    if (payload != null) {
      handlePayload(device.ipAddress!, payload).then(
        (value) {
          infoLog('Received payload of size ${value.length}!');
        },
        onError: (e) {
          errorLog(e);
        },
      );
    }
  }

  void _addNotification(NotificationData notification) {
    _notifications.add(notification);
    notifier.add({'notifications': notifications});
  }

  void clearNotification([NotificationData? notification]) {
    if (notification != null) {
      _notifications.remove(notification);
    } else {
      _notifications.clear();
    }
    notifier.add({'notifications': notifications});
  }
}

class NotificationData {
  NotificationData({
    required this.timestamp,
    required this.appName,
    required this.title,
    required this.text,
  });

  final int timestamp;
  final String appName;
  final String title;
  final String text;
}

Future<Uint8List> handlePayload(String address, DeviceMessagePayload payload) async {
  debugLog('Start receiving payload from $address:${payload.port}...');
  return Isolate.run<Uint8List>(() async {
    final completer = Completer<Uint8List>();
    try {
      final socket = await Socket.connect(address, payload.port);
      final Uint8List data = Uint8List(payload.size);
      var progress = 0;
      infoLog('Progress: 0%');
      socket.listen((event) {
        data.setRange(progress, progress + event.length, event);
        progress += event.length;
        infoLog('Progress: ${(progress / payload.size) * 100}%');
        if (progress == payload.size) {
          socket.close();
          completer.complete(data);
        }
      });
    } on Exception catch (e) {
      completer.completeError(e);
    }
    return completer.future;
  });
}
