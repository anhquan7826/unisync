import '../events/device_disconnected.event.dart';
import 'base_event_handler.dart';

abstract class DeviceDisconnectedEventHandler extends BaseEventHandler {
  void onDeviceDisconnectedEvent(DeviceDisconnectedEvent event);
}
