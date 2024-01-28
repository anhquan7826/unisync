import '../events/device_connected.event.dart';
import 'base_event_handler.dart';

abstract class DeviceConnectedEventHandler extends BaseEventHandler {
  void onDeviceConnectedEvent(DeviceConnectedEvent event);
}
