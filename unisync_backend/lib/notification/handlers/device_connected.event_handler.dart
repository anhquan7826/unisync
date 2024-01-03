import 'package:unisync_backend/notification/events/device_connected.event.dart';
import 'package:unisync_backend/notification/handlers/base_event_handler.dart';

abstract class DeviceConnectedEventHandler extends BaseEventHandler {
  void onDeviceConnectedEvent(DeviceConnectedEvent event);
}
