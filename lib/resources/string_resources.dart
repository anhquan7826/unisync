class StringResources {
  final appName = 'Unisync';

  final landing = _Landing();
  final devicesStatus = _DevicesStatusText();
  final status = _Status();

  final labelContinue = 'continue';
}

class _Landing {
  final welcome = 'landing.welcome';
  final description = 'landing.description';
}

class _DevicesStatusText {
  final title = 'devices_status.title';
  final connectedDevice = 'devices_status.connected_devices';
  final disconnectedDevice = 'devices_status.disconnected_devices';
  final addDevice = 'devices_status.add_device';
  final noDeviceFound = 'devices_status.no_devices_found';
  final noConnectedDevices = 'devices_status.no_connected_devices';
  final availableDevices = 'devices_status.available_devices';
  final pairedDevices = 'devices_status.paired_devices';
  final rescan = 'devices_status.rescan';
}

class _Status {
  final connected = 'status.connected';
  final status = 'status.disconnected';
}
