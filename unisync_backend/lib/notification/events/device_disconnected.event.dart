import 'package:unisync_backend/models/device_info/device_info.model.dart';
import 'package:unisync_backend/notification/events/base_event.dart';

class DeviceDisconnectedEvent extends BaseEvent {
  DeviceDisconnectedEvent(this.device);

  final DeviceInfo device;
}
