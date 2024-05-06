import 'package:flutter/services.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/device_connection.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/logger.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SharingPlugin extends UnisyncPlugin {
  SharingPlugin(Device device)
      : super(device, type: DeviceMessage.Type.SHARING);
  static const _method = (
    OPEN_URL: 'open_url',
    COPY_TEXT: 'copy_text',
  );

  @override
  void onReceive(
      DeviceMessageHeader header, Map<String, dynamic> data, Payload? payload) {
    super.onReceive(header, data, payload);
    if (header.method == _method.OPEN_URL) {
      _handleUrl(data['url']);
    }
    if (header.method == _method.COPY_TEXT) {
      _handleText(data['text']);
    }
  }

  void _handleUrl(String url) {
    debugLog('handling url: $url');
    launchUrlString(url);
  }

  void _handleText(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}
