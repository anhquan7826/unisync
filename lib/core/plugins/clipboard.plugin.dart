import 'dart:async';

import 'package:flutter/services.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';
import 'package:unisync/utils/logger.dart';

class ClipboardPlugin extends UnisyncPlugin {
  ClipboardPlugin(super.emitter) {
    if (_clipboard != null) {
      _clipboardListener = ClipboardListener(channel);
      _clipboardListener!.listen((content) {
        if (_latestClipboard != content) {
          _latestClipboard = content;
          emitter.sendMessage(DeviceMessage(
            type: DeviceMessage.Type.CLIPBOARD,
            body: {
              'clipboard': content,
            },
          ));
        }
      });
    }
  }

  final channel = const MethodChannel('com.anhquan.unisync/clipboard');
  final _clipboard = SystemClipboard.instance;
  ClipboardListener? _clipboardListener;
  var _latestClipboard = '';

  @override
  bool isPluginMessage(DeviceMessage message) {
    return message.type == DeviceMessage.Type.CLIPBOARD;
  }

  @override
  void onMessageReceived(DeviceMessage message) {
    message.body['clipboard']?.toString().let((it) async {
      if (_latestClipboard == it) {
        return;
      }
      _latestClipboard = it;
      await channel.invokeMethod('set', it);
      // await Clipboard.setData(ClipboardData(text: it));
      debugLog('wrote clipboard: $it');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _clipboardListener?.dispose();
  }
}

class ClipboardListener {
  ClipboardListener(this.channel) {
    _start();
  }

  final MethodChannel channel;

  void Function(String)? _listener;
  Timer? _timer;

  var _prevContent = '';

  Future<void> _start() async {
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      // Clipboard.getData('text/plain').then((value) {
      //   value?.text?.let((it) {
      //     debugLog('read clipboard: $it');
      //     if (_prevContent != it) {
      //       _prevContent = it;
      //       _listener?.call(it);
      //     }
      //   });
      // });
      channel.invokeMethod('get').then((value) {
        value?.toString().let((it) {
          debugLog('read clipboard: $it');
          if (_prevContent != it) {
            _prevContent = it;
            _listener?.call(it);
          }
        });
      });
    });
  }

  void listen(void Function(String) onClipboard) {
    _listener = onClipboard;
  }

  void dispose() {
    _timer?.cancel();
  }
}
