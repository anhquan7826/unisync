import 'package:unisync_backend/notification/events/base_event.dart';
import 'package:unisync_backend/notification/events/device_connected.event.dart';
import 'package:unisync_backend/notification/handlers/base_event_handler.dart';
import 'package:unisync_backend/notification/handlers/device_connected.event_handler.dart';
import 'package:unisync_backend/notification/handlers/device_disconnected.event_handler.dart';
import 'package:unisync_backend/utils/logger.dart';

import 'events/device_disconnected.event.dart';

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
