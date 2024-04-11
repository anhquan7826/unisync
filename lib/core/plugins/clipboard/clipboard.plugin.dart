import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flutter/services.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';

import '../../device.dart';

class ClipboardPlugin extends UnisyncPlugin with ClipboardListener {
  ClipboardPlugin(Device device) : super(device, type: DeviceMessage.Type.CLIPBOARD) {
    clipboardWatcher
      ..addListener(this)
      ..start();
  }

  @override
  Future<void> onClipboardChanged() async {
    final content = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    if (content != null && _latestClipboard != content) {
      _latestClipboard = content;
      send({'clipboard': content});
    }
  }

  var _latestClipboard = '';

  @override
  void onReceive(Map<String, dynamic> data, DeviceMessagePayload? payload) {
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
