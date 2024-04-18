import 'package:unisync/core/device.dart';
import 'package:unisync/core/device_connection.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

class StatusPlugin extends UnisyncPlugin {
  StatusPlugin(Device device) : super(device, type: DeviceMessage.Type.STATUS);
  static const _Method = (
    GET_STATUS: 'get_status',
    STATUS_CHANGED: 'status_changed',
  );

  @override
  void onReceive(DeviceMessageHeader header, Map<String, dynamic> data, Payload? payload) {
    super.onReceive(header, data, payload);
    if (header.method == _Method.STATUS_CHANGED) {
      notifier.add(data);
    }
  }

  void sendStatusRequest() {
    sendRequest(_Method.GET_STATUS);
  }
}
