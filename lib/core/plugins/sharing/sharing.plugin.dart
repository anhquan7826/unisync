import 'package:flutter/services.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/logger.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SharingPlugin extends UnisyncPlugin {
  SharingPlugin(Device device)
      : super(device, type: DeviceMessage.Type.SHARING);

  @override
  void onReceive(Map<String, dynamic> data, DeviceMessagePayload? payload) {
    if (data.containsKey('url')) {
      _handleUrl(data['url']);
    }
    if (data.containsKey('text')) {
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
