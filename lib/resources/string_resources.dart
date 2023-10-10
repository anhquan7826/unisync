class StringResources {
  final appName = 'Unisync';

  final landing = _Landing();
  final devices = _Devices();

  final labelContinue = 'continue';
}

class _Landing {
  final welcome = 'landing.welcome';
  final description = 'landing.description';
}

class _Devices {
  final title = 'devices.title';
  final connectedDevice = 'devices.connected_devices';
  final disconnectedDevice = 'devices.disconnected_devices';
  final addDevice = 'devices.add_device';
}
