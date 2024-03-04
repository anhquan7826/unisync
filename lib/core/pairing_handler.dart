import 'package:unisync/utils/logger.dart';

import '../database/unisync_database.dart';
import '../models/device_message/device_message.model.dart';
import 'device.dart';
import 'device_provider.dart';

enum PairState { unpaired, paired, pairRequested }

abstract interface class PairOperation {
  void acceptPair();

  void rejectPair();
}

class PairingHandler implements PairOperation {
  PairingHandler(this.device) {
    UnisyncDatabase.pairedDeviceDao.exist(device.info.id).then((value) {
      if (value) {
        _state = PairState.paired;
      } else {
        _state = PairState.unpaired;
      }
      debugLog('PairingHandler@${device.info.name}: $_state');
      _notify();
    });
  }

  final Device device;

  var _state = PairState.unpaired;

  PairState get state => _state;

  @override
  void acceptPair() {
    if (_state == PairState.pairRequested) {
      device.connection.send(DeviceMessage(
        type: DeviceMessage.Type.PAIR,
        body: {
          'message': 'accepted',
        },
      ));
      UnisyncDatabase.pairedDeviceDao.add(device.info);
      _state = PairState.paired;
      _notify();
    }
  }

  @override
  void rejectPair() {
    if (_state == PairState.pairRequested) {
      device.connection.send(DeviceMessage(
        type: DeviceMessage.Type.PAIR,
        body: {
          'message': 'rejected',
        },
      ));
      _state = PairState.unpaired;
      _notify();
    }
  }

  void unpair() {
    if (_state == PairState.paired) {
      device.connection.send(DeviceMessage(
        type: DeviceMessage.Type.PAIR,
        body: {
          'message': 'unpair',
        },
      ));
      UnisyncDatabase.pairedDeviceDao.remove(device.info.id);
      _state = PairState.unpaired;
      _notify();
    }
  }

  void onMessageReceived(DeviceMessage message) {
    if (message.type == DeviceMessage.Type.PAIR && message.body.containsKey('message')) {
      switch (message.body['message'].toString()) {
        case 'requested':
          {
            _state = PairState.pairRequested;
            _notify();
            break;
          }
        case 'unpair':
          {
            UnisyncDatabase.pairedDeviceDao.remove(device.info.id);
            _state = PairState.unpaired;
            _notify();
            break;
          }
      }
    }
  }

  void _notify() {
    DeviceProvider.deviceNotifier.add(DeviceNotification(
      device: device.info,
      pairState: _state,
    ));
  }
}
