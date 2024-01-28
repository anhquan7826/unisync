import 'package:unisync/notification/events/base_event.dart';

import '../utils/logger.dart';
import 'events/device_connected.event.dart';
import 'events/device_disconnected.event.dart';
import 'handlers/base_event_handler.dart';
import 'handlers/device_connected.event_handler.dart';
import 'handlers/device_disconnected.event_handler.dart';

class UnisyncEventNotifier {
  UnisyncEventNotifier._();

  static final _deviceConnected = <DeviceConnectedEventHandler>{};
  static final _deviceDisconnected = <DeviceDisconnectedEventHandler>{};

  static void register(BaseEventHandler listener) {
    if (listener is DeviceConnectedEventHandler) {
      _deviceConnected.add(listener);
      debugLog('Registered DeviceConnectedEventHandler(${listener.hashCode})');
    }
    if (listener is DeviceDisconnectedEventHandler) {
      _deviceDisconnected.add(listener);
      debugLog('Registered DeviceDisconnectedEventHandler(${listener.hashCode})');
    }
  }

  static void unregister(BaseEventHandler listener) {
    if (listener is DeviceConnectedEventHandler) {
      _deviceConnected.remove(listener);
      debugLog('Unregistered DeviceConnectedEventHandler(${listener.hashCode})');
    }
    if (listener is DeviceDisconnectedEventHandler) {
      _deviceDisconnected.remove(listener);
      debugLog('Unregistered DeviceDisconnectedEventHandler(${listener.hashCode})');
    }
  }

  static void publish(BaseEvent event) {
    if (event is DeviceConnectedEvent) {
      for (final element in _deviceConnected) {
        element.onDeviceConnectedEvent(event);
      }
    }
    if (event is DeviceDisconnectedEvent) {
      for (final element in _deviceDisconnected) {
        element.onDeviceDisconnectedEvent(event);
      }
    }
  }
}
