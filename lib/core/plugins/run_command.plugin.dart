import 'dart:io';

import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

class RunCommandPlugin extends UnisyncPlugin {
  RunCommandPlugin(super.emitter);

  @override
  bool isPluginMessage(DeviceMessage message) {
    return message.type == DeviceMessage.Type.RUN_COMMAND;
  }

  @override
  void onMessageReceived(DeviceMessage message) {
    final command = message.body['command']!.toString().split(' ');
    final executable = command[0];
    final arguments = command.getRange(1, command.length).toList();
    Process.start(
      executable,
      arguments,
      runInShell: true,
    );
  }
}
