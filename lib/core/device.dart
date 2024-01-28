import 'package:unisync/core/pairing_handler.dart';

import '../models/device_info/device_info.model.dart';
import '../models/device_message/device_message.model.dart';
import 'device_connection.dart';

class Device extends ConnectionListener {
  Device(this.connection) {
    connection.messageListener = this;
  }

  final DeviceConnection connection;
  late final DeviceInfo info = connection.info;

  late final PairingHandler _pairingHandler = PairingHandler(this);

  PairState get pairState => _pairingHandler.state;

  @override
  void onMessage(DeviceMessage message) {
    _pairingHandler.onMessageReceived(message);
    if (_pairingHandler.state == PairState.paired) {}
  }
}
