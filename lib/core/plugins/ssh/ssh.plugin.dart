// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:process_run/shell.dart';
import 'package:unisync/components/resources/resources.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/device_connection.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

class SSHPlugin extends UnisyncPlugin {
  SSHPlugin(Device device) : super(device, type: DeviceMessage.Type.SSH);

  static const _method = (
    SETUP: 'setup',
    GET_USERNAME: 'get_username',
  );

  @override
  void onReceive(
    DeviceMessageHeader header,
    Map<String, dynamic> data,
    Payload? payload,
  ) {
    super.onReceive(header, data, payload);
    if (header.type == DeviceMessageHeader.Type.REQUEST) {
      if (header.method == _method.SETUP) {
        rootBundle.loadString(R.scripts.setup_ssh).then((script) {
          Shell().run(script).then((value) {
            final success = value.every((element) => element.exitCode == 0);
            sendResponse(
              _method.SETUP,
              data: {
                'result': success ? 'success' : 'failed',
              },
            );
          });
        });
      }
      if (header.method == _method.GET_USERNAME) {
        sendResponse(
          _method.GET_USERNAME,
          data: {
            'username': Platform.environment['LOGNAME'],
          },
        );
      }
    }
  }
}
