import 'package:unisync/core/pairing_handler.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/core/plugins/battery.plugin.dart';
import 'package:unisync/core/plugins/clipboard.plugin.dart';
import 'package:unisync/core/plugins/notification_plugin.dart';
import 'package:unisync/core/plugins/volume.plugin.dart';

import '../models/device_info/device_info.model.dart';
import '../models/device_message/device_message.model.dart';
import 'device_connection.dart';

class Device with ConnectionListener, ConnectionEmitter {
  Device(this.connection) {
    connection.connectionListener = this;
    plugins = [
      BatteryPlugin(this),
      ClipboardPlugin(this),
      NotificationPlugin(this),
      VolumePlugin(this),
    ];
  }

  final DeviceConnection connection;
  late final DeviceInfo info = connection.info;

  late final PairingHandler _pairingHandler = PairingHandler(this);

  late final List<UnisyncPlugin> plugins;

  PairState get pairState => _pairingHandler.state;

  @override
  void onMessage(DeviceMessage message) {
    _pairingHandler.onMessageReceived(message);
    if (/*_pairingHandler.state == PairState.paired*/ true) {
      for (final plugin in plugins) {
        if (plugin.isPluginMessage(message)) {
          plugin.onMessageReceived(message);
        }
      }
    }
  }

  @override
  void sendMessage(DeviceMessage message) {
    connection.send(message);
  }

  T getPlugin<T extends UnisyncPlugin>() {
    return plugins.firstWhere((element) => element is T) as T;
  }

  @override
  void onDisconnected() {
    for (final plugin in plugins) {
      plugin.dispose();
    }
  }
}
