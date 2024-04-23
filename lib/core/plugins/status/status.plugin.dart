// ignore_for_file: non_constant_identifier_names
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
  );

  @override
  void onReceive(
      DeviceMessageHeader header, Map<String, dynamic> data, Payload? payload) {
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
  }

  void sendStatusRequest() {
    sendRequest(_method.GET_STATUS);
  }
}
