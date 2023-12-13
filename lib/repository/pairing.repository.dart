// ignore_for_file: constant_identifier_names

import 'package:unisync/models/device_info/device_info.model.dart';

// TODO: Separate device connection flow and message flow

abstract class PairingRepository {
  /// Get paired devices, include connected and disconnected devices.
  /// Use [addDeviceStateListener] to get the device's state.
  Future<List<DeviceInfo>> getPairedDevices();

  /// Get unpaired devices. These devices are connected but not paired.
  Future<List<DeviceInfo>> getUnpairedDevices();

  Future<bool> isDeviceOnline(DeviceInfo device);

  Future<bool> isDevicePaired(DeviceInfo device);

  Future<bool> addDeviceManually(String ip);

  /// Add a state listener to a device connection. Callbacks are called immediately upon registering.
  void addDeviceStateListener(DeviceStateCallback callback);

  /// Remove the registered state listener to a device.
  void removeDeviceStateListener(DeviceStateCallback callback);
}

class DeviceStateCallback {
  DeviceStateCallback({required this.onDeviceConnected, required this.onDeviceDisconnected});

  final void Function(DeviceInfo) onDeviceConnected;
  final void Function(DeviceInfo) onDeviceDisconnected;
}
