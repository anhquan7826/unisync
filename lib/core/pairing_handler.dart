import 'package:unisync/database/database.dart';
import 'package:unisync/database/entity/paired_device.entity.dart';

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
    final value = await UnisyncDatabase.i.pairedDeviceDao.exist(device.info.id);
    if (value == 1) {
      _state = PairState.paired;
    } else {
      _state = PairState.unpaired;
    }
    onStateChanged(_state);
  }

  @override
  void acceptPair() {
    if (_state == PairState.pairRequested) {
      device.sendMessage(DeviceMessage(
        type: DeviceMessage.Type.PAIR,
        body: {
          'message': 'accepted',
        },
      ));
      UnisyncDatabase.i.pairedDeviceDao.add(PairedDeviceEntity(
        id: device.info.id,
        name: device.info.name,
        type: device.info.deviceType,
      ));
      _state = PairState.paired;
      onStateChanged(_state);
    }
  }

  @override
  void rejectPair() {
    if (_state == PairState.pairRequested) {
      device.sendMessage(DeviceMessage(
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
        type: DeviceMessage.Type.PAIR,
        body: {
          'message': 'unpair',
        },
      ));
      UnisyncDatabase.i.pairedDeviceDao.remove(device.info.id);
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
          UnisyncDatabase.i.pairedDeviceDao.remove(device.info.id);
          _state = PairState.unpaired;
          onStateChanged(_state);
          break;
        }
    }
  }
}
