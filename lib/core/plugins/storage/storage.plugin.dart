import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/extensions/stream.ext.dart';

class StoragePlugin extends UnisyncPlugin {
  StoragePlugin(Device device)
      : super(device, type: DeviceMessage.Type.STORAGE);
  static const _Method = (START_SERVER: 'start_server',);

  Future<(int, String, String)> startServer() {
    final c = completer<(int, String, String)>();
    sendRequest(_Method.START_SERVER);
    messages.listenCancellable((event) {
      if (event.header.type == DeviceMessageHeader.Type.RESPONSE &&
          event.header.method == _Method.START_SERVER) {
        complete(c, value: (
          event.data['port'],
          event.data['username'],
          event.data['password'],
        ));
        return true;
      }
      return false;
    });
    return future(c);
  }
}
