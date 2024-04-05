import 'dart:io';

import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

import '../../device.dart';

class RunCommandPlugin extends UnisyncPlugin {
  RunCommandPlugin(Device device) : super(device, type: DeviceMessage.Type.RUN_COMMAND);

  @override
  void onReceive(Map<String, dynamic> data, DeviceMessagePayload? payload) {
    final command = data['command']!.toString().split(' ');
    final executable = command[0];
    final arguments = command.getRange(1, command.length).toList();
    Process.start(
      executable,
      arguments,
      runInShell: true,
    );
  }
}
