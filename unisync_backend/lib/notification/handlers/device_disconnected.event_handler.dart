import 'package:unisync_backend/notification/handlers/base_event_handler.dart';

import '../events/device_disconnected.event.dart';

abstract class DeviceDisconnectedEventHandler extends BaseEventHandler {
  void onDeviceDisconnectedEvent(DeviceDisconnectedEvent event);
}
