import 'dart:async';

import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/device_connection.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

class VolumePlugin extends UnisyncPlugin {
  VolumePlugin(Device device) : super(device, type: DeviceMessage.Type.VOLUME) {
    _subscription = FlutterVolumeController.addListener((value) {
      if (!_isChangingByPeer) {
        sendNotification(
          _Method.VOLUME_CHANGED,
          data: {'volume': value},
        );
      }
    });
  }

  static const _Method = (
    GET_VOLUME: 'get_volume',
    SET_VOLUME: 'set_volume',
    VOLUME_CHANGED: 'volume_changed'
  );

  late final StreamSubscription<double> _subscription;

  bool _isChangingByPeer = false;
  late final debounce = _Debouncer(
    // duration: const Duration(seconds: 2),
    callback: () {
      _isChangingByPeer = false;
    },
  );

  @override
  Future<void> onReceive(
    DeviceMessageHeader header,
    Map<String, dynamic> data,
    Payload? payload,
  ) async {
    super.onReceive(header, data, payload);
    if (header.method == _Method.SET_VOLUME) {
      _setVolume(data['set_volume']);
    }
    if (header.method == _Method.GET_VOLUME) {
      sendNotification(
        _Method.VOLUME_CHANGED,
        data: {
          'volume': await FlutterVolumeController.getVolume(),
        },
      );
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
  _Debouncer(
      {this.duration = const Duration(milliseconds: 500),
      required this.callback});

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
