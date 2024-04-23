// ignore_for_file: non_constant_identifier_names
import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flutter/services.dart';
import 'package:unisync/core/device_connection.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';

import '../../device.dart';

class ClipboardPlugin extends UnisyncPlugin with ClipboardListener {
  ClipboardPlugin(Device device)
      : super(device, type: DeviceMessage.Type.CLIPBOARD) {
    clipboardWatcher
      ..addListener(this)
      ..start();
  }

  static const _method = (CLIPBOARD_CHANGED: 'clipboard_changed',);

  @override
  Future<void> onClipboardChanged() async {
    final content = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    if (content != null && _latestClipboard != content) {
      _latestClipboard = content;
      sendNotification(
        _method.CLIPBOARD_CHANGED,
        data: {'clipboard': content},
      );
    }
  }

  var _latestClipboard = '';

  @override
  void onReceive(
    DeviceMessageHeader header,
    Map<String, dynamic> data,
    Payload? payload,
  ) {
    super.onReceive(header, data, payload);
    data['clipboard']?.toString().let((it) async {
      if (_latestClipboard == it) {
        return;
      }
      _latestClipboard = it;
      Clipboard.setData(ClipboardData(text: it));
    });
  }

  @override
  void dispose() {
    super.dispose();
    clipboardWatcher
      ..stop()
      ..removeListener(this);
  }
}
