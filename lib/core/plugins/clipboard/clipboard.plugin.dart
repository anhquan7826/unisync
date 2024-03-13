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
  void onReceive(Map<String, dynamic> data) {
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

// class ClipboardListener {
//   ClipboardListener(this.channel) {
//     _start();
//   }
//
//   final MethodChannel channel;
//
//   void Function(String)? _listener;
//   Timer? _timer;
//
//   var _prevContent = '';
//
//   Future<void> _start() async {
//     _timer = Timer.periodic(const Duration(seconds: 20), (_) {
//       // Clipboard.getData('text/plain').then((value) {
//       //   value?.text?.let((it) {
//       //     debugLog('read clipboard: $it');
//       //     if (_prevContent != it) {
//       //       _prevContent = it;
//       //       _listener?.call(it);
//       //     }
//       //   });
//       // });
//       channel.invokeMethod('get').then((value) {
//         value?.toString().let((it) {
//           debugLog('read clipboard: $it');
//           if (_prevContent != it) {
//             _prevContent = it;
//             _listener?.call(it);
//           }
//         });
//       });
//     });
//   }
//
//   void listen(void Function(String) onClipboard) {
//     _listener = onClipboard;
//   }
//
//   void dispose() {
//     _timer?.cancel();
//   }
// }
