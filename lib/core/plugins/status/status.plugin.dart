// ignore_for_file: non_constant_identifier_names
import 'package:process_run/process_run.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/device_connection.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/payload_handler.dart';

class StatusPlugin extends UnisyncPlugin {
  StatusPlugin(Device device) : super(device, type: DeviceMessage.Type.STATUS);
  static const _method = (
    GET_STATUS: 'get_status',
    STATUS_CHANGED: 'status_changed',
    SHUT_DOWN: 'shut_down',
    RESTART: 'restart',
    LOCK: 'lock'
  );

  @override
  void onReceive(
    DeviceMessageHeader header,
    Map<String, dynamic> data,
    Payload? payload,
  ) {
    super.onReceive(header, data, payload);
    if (header.method == _method.STATUS_CHANGED) {
      if (payload != null) {
        getPayloadData(payload.stream, size: payload.size).then((value) {
          notifier.add({
            ...data,
            'wallpaper': value,
          });
        });
      } else {
        notifier.add(data);
      }
    }
    if (header.method == _method.SHUT_DOWN) {
      Shell().run('shutdown -P now');
    }
    if (header.method == _method.RESTART) {
      Shell().run('shutdown -r now');
    }
    if (header.method == _method.LOCK) {
      Shell().run('loginctl lock-session');
    }
  }

  void sendStatusRequest() {
    sendRequest(_method.GET_STATUS);
  }
}
