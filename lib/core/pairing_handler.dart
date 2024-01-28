import '../database/unisync_database.dart';
import '../models/device_message/device_message.model.dart';
import 'device.dart';
import 'device_provider.dart';

enum PairState { notPaired, paired, requested, requestedByPeer }

class PairingHandler {
  PairingHandler(this.device) {
    UnisyncDatabase.pairedDeviceDao.exist(device.info.id).then((value) {
      if (value) {
        _state = PairState.paired;
      } else {
        _state = PairState.notPaired;
      }
    });
  }

  final Device device;

  var _state = PairState.notPaired;

  PairState get state => _state;

  void acceptPair() {
    if (_state == PairState.requestedByPeer) {
      device.connection.send(DeviceMessage(
        type: DeviceMessage.Type.PAIR,
        body: {
          'message': 'accepted',
        },
      ));
      UnisyncDatabase.pairedDeviceDao.add(device.info);
      _state = PairState.paired;
    }
  }

  void rejectPair() {
    if (_state == PairState.requestedByPeer) {
      device.connection.send(DeviceMessage(
        type: DeviceMessage.Type.PAIR,
        body: {
          'message': 'rejected',
        },
      ));
      _state = PairState.notPaired;
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
      _state = PairState.notPaired;
    }
  }

  void onMessageReceived(DeviceMessage message) {
    if (message.type == DeviceMessage.Type.PAIR && message.body.containsKey('message')) {
      switch (message.body['message'].toString()) {
        case 'requested':
          {
            _state = PairState.requestedByPeer;
            DeviceProvider.currentRequestedDevices.add(device.info);
            break;
          }
        case 'unpair':
          {
            UnisyncDatabase.pairedDeviceDao.remove(device.info.id);
            _state = PairState.notPaired;
            break;
          }
      }
    }
  }
}
