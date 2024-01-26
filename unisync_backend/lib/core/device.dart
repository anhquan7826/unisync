import 'package:unisync_backend/core/device_connection.dart';
import 'package:unisync_backend/core/pairing_handler.dart';
import 'package:unisync_backend/models/device_info/device_info.model.dart';
import 'package:unisync_backend/models/device_message/device_message.model.dart';

class Device extends ConnectionListener {
  Device(this.connection) {
    connection.messageListener = this;
  }

  final DeviceConnection connection;
  late final DeviceInfo info = connection.info;

  late final PairingHandler _pairingHandler = PairingHandler(this);

  @override
  void onMessage(DeviceMessage message) {
    _pairingHandler.onMessageReceived(message);
    if (_pairingHandler.state == PairState.paired) {}
  }
}
