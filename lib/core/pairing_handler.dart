import 'package:unisync/utils/configs.dart';

import '../models/device_message/device_message.model.dart';
import 'device.dart';

enum PairState { unpaired, paired, pairRequested, unknown }

abstract interface class PairOperation {
  void acceptPair();

  void rejectPair();

  void unpair();
}

class PairingHandler implements PairOperation {
  PairingHandler(this.device, {required this.onStateChanged});

  final Device device;
  final void Function(PairState state) onStateChanged;

  var _state = PairState.unknown;

  bool get isReady => _state != PairState.unknown;

  PairState get state => _state;

  Future<void> initiate() async {
    final info = await ConfigUtil.device.getPairedDeviceInfo(device.info.id);
    if (info != null) {
      _state = PairState.paired;
      if (info.toString() != device.info.toString()) {
        ConfigUtil.device.addPairedDevice(device.info);
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
        body: {
          'message': 'accepted',
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
        body: {
          'message': 'rejected',
        },
      ));
      _state = PairState.unpaired;
      onStateChanged(_state);
    }
  }

  @override
  void unpair() {
    if (_state == PairState.paired) {
      device.sendMessage(DeviceMessage(
        time: DateTime.now().millisecondsSinceEpoch,
        type: DeviceMessage.Type.PAIR,
        body: {
          'message': 'unpair',
        },
      ));
      ConfigUtil.device.removePairedDevice(device.info);
      _state = PairState.unpaired;
      onStateChanged(_state);
    }
  }

  void handle(Map<String, dynamic> messageBody) {
    switch (messageBody['message'].toString()) {
      case 'requested':
        {
          if (_state == PairState.unpaired) {
            _state = PairState.pairRequested;
            onStateChanged(_state);
          }
          break;
        }
      case 'unpair':
        {
          ConfigUtil.device.removePairedDevice(device.info);
          _state = PairState.unpaired;
          onStateChanged(_state);
          break;
        }
    }
  }
}
