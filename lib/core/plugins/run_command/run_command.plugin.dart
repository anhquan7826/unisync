// ignore_for_file: non_constant_identifier_names
import 'dart:io';

import 'package:unisync/core/device.dart';
import 'package:unisync/core/device_connection.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/push_notification.dart';

class RunCommandPlugin extends UnisyncPlugin {
  RunCommandPlugin(Device device)
      : super(device, type: DeviceMessage.Type.RUN_COMMAND);
  static const _method = (EXECUTE: 'execute',);

  @override
  void onReceive(
    DeviceMessageHeader header,
    Map<String, dynamic> data,
    Payload? payload,
  ) {
    super.onReceive(header, data, payload);
    final command = data['command']!.toString().split(' ');
    final executable = command[0];
    final arguments = command.getRange(1, command.length).toList();
    Process.start(
      executable,
      arguments,
      runInShell: true,
    ).then((value) async {
      PushNotification.showNotification(
        title: 'Run command',
        text: 'Executing command "$command"...',
      );
    });
  }
}
