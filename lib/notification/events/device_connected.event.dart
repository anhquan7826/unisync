import '../../models/device_info/device_info.model.dart';
import 'base_event.dart';

class DeviceConnectedEvent extends BaseEvent {
  DeviceConnectedEvent(this.device);

  final DeviceInfo device;
}
