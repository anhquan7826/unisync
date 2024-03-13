import 'dart:async';

import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

import '../../device.dart';

class VolumePlugin extends UnisyncPlugin {
  VolumePlugin(Device device) : super(device, type: DeviceMessage.Type.VOLUME) {
    _subscription = FlutterVolumeController.addListener((value) {
      if (!_isChangingByPeer) {
        send({'volume': value});
      }
    });
  }

  late final StreamSubscription<double> _subscription;

  bool _isChangingByPeer = false;
  late final debounce = _Debouncer(callback: () {
    _isChangingByPeer = false;
  });

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
    _isChangingByPeer = true;
    debounce.execute();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _Debouncer {
  _Debouncer({this.duration = const Duration(milliseconds: 500), required this.callback});

  final void Function() callback;
  final Duration duration;
  Timer? timer;

  void execute() {
    if (timer == null || timer!.isActive) {
      timer?.cancel();
      timer = Timer(duration, callback);
    } else {
      timer = Timer(duration, callback);
    }
  }
}
