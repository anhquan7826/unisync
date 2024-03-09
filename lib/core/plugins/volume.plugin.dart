import 'dart:async';

import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/logger.dart';

import '../device.dart';

class VolumePlugin extends UnisyncPlugin {
  VolumePlugin(Device device) : super(device, type: DeviceMessage.Type.NOTIFICATION) {
    _notifier = _VolumeChangeNotifier((value) {
      send({'volume': value});
    });
  }

  late final _VolumeChangeNotifier _notifier;

  @override
  Future<void> onReceive(Map<String, dynamic> data) async {
    if (data.containsKey('set_volume')) {
      _setVolume(data['set_volume']);
    }
    if (data.containsKey('get_volume')) {
      send({'volume': await FlutterVolumeController.getVolume()});
    }
  }

  Future<void> _setVolume(double value) async {
    await FlutterVolumeController.setVolume(value);
  }

  @override
  void dispose() {
    _notifier.stop();
    super.dispose();
  }
}

class _VolumeChangeNotifier {
  _VolumeChangeNotifier(
    this.listener, {
    this.duration = const Duration(milliseconds: 100),
  }) {
    start();
  }

  final Duration duration;
  final void Function(double value) listener;

  late Timer? _timer;
  double _preVolume = 0;

  void start() {
    debugLog('alo');
    _timer = Timer(duration, () async {
      final volume = await FlutterVolumeController.getVolume();
      if (volume != null && volume != _preVolume) {
        _preVolume = volume;
        listener(volume);
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
