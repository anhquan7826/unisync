// ignore_for_file: non_constant_identifier_names
import 'package:unisync/utils/configs.dart';

import '../models/device_message/device_message.model.dart';
import 'device.dart';

enum PairState { unpaired, paired, pairRequested, markUnpaired, unknown }

abstract interface class PairOperation {
  void acceptPair();

  void rejectPair();

  void unpair();
}

class PairingHandler implements PairOperation {
  PairingHandler(this.device, {required this.onStateChanged});

  static const _method = (
    REQUEST: 'request',
    UNPAIR: 'unpair',
  );

  final Device device;
  final void Function(PairState state) onStateChanged;

  var _state = PairState.unknown;

  bool get isReady => _state != PairState.unknown;

  PairState get state => _state;

  Future<void> initiate() async {
    final result = await ConfigUtil.device.getPairedDeviceInfo(device.info.id);
    final info = result?.$1;
    final markUnpaired = result?.$2;
    if (result != null) {
      if (markUnpaired == true) {
        _state = PairState.markUnpaired;
      } else {
        _state = PairState.paired;
        if (info.toString() != device.info.toString()) {
          ConfigUtil.device.addPairedDevice(device.info);
        }
      }
    } else {
      _state = PairState.unpaired;
    }
    onStateChanged(_state);
  }

  @override
  void acceptPair() {
    if (_state == PairState.pairRequested) {
      device.sendMessage(DeviceMessage(
        time: DateTime.now().millisecondsSinceEpoch,
        type: DeviceMessage.Type.PAIR,
        header: DeviceMessageHeader(
          type: DeviceMessageHeader.Type.RESPONSE,
          status: DeviceMessageHeader.Status.SUCCESS,
          method: _method.REQUEST,
        ),
        body: {
          'accepted': true,
        },
      ));
      ConfigUtil.device.addPairedDevice(device.info);
      _state = PairState.paired;
      onStateChanged(_state);
    }
  }

  @override
  void rejectPair() {
    if (_state == PairState.pairRequested) {
      device.sendMessage(DeviceMessage(
        time: DateTime.now().millisecondsSinceEpoch,
        type: DeviceMessage.Type.PAIR,
        header: DeviceMessageHeader(
          type: DeviceMessageHeader.Type.RESPONSE,
          status: DeviceMessageHeader.Status.SUCCESS,
          method: _method.REQUEST,
        ),
        body: {
          'accepted': false,
        },
      ));
      _state = PairState.unpaired;
      onStateChanged(_state);
    }
  }

  @override
  void unpair() {
    if (_state == PairState.paired || _state == PairState.markUnpaired) {
      device.sendMessage(DeviceMessage(
        time: DateTime.now().millisecondsSinceEpoch,
        type: DeviceMessage.Type.PAIR,
        header: DeviceMessageHeader(
          type: DeviceMessageHeader.Type.NOTIFICATION,
          method: _method.UNPAIR,
        ),
      ));
      ConfigUtil.device.removePairedDevice(device.info);
      _state = PairState.unpaired;
      onStateChanged(_state);
    }
  }

  void handle(DeviceMessage message) {
    if (message.header.method == _method.REQUEST) {
      if (_state == PairState.unpaired) {
        _state = PairState.pairRequested;
        onStateChanged(_state);
      }
    }
    if (message.header.method == _method.UNPAIR) {
      ConfigUtil.device.removePairedDevice(device.info);
      _state = PairState.unpaired;
      onStateChanged(_state);
    }
  }
}
