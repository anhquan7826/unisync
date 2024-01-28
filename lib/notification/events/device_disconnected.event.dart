import '../../models/device_info/device_info.model.dart';
import 'base_event.dart';

class DeviceDisconnectedEvent extends BaseEvent {
  DeviceDisconnectedEvent(this.device);

  final DeviceInfo device;
}
