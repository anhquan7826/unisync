import 'package:rxdart/rxdart.dart';
import 'package:unisync/core/pairing_handler.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/core/plugins/battery.plugin.dart';
import 'package:unisync/core/plugins/clipboard.plugin.dart';
import 'package:unisync/core/plugins/notification_plugin.dart';
import 'package:unisync/core/plugins/ring_phone.plugin.dart';
import 'package:unisync/core/plugins/run_command.plugin.dart';
import 'package:unisync/core/plugins/volume.plugin.dart';

import '../models/device_info/device_info.model.dart';
import '../models/device_message/device_message.model.dart';
import 'device_connection.dart';
import 'device_provider.dart';

class Device with ConnectionListener {
  factory Device(DeviceInfo info) {
    _instances[info] ??= Device._(info);
    return _instances[info]!;
  }

  factory Device.fromId(String id) {
    return _instances[DeviceInfo(id: id, name: '', deviceType: '')]!;
  }

  Device._(this.info) {
    _initiate();
  }

  static final Map<DeviceInfo, Device> _instances = {};

  final DeviceInfo info;

  String? get ipAddress => _connection?.ipAddress;
  DeviceConnection? _connection;

  DeviceConnection? get connection => _connection;

  set connection(DeviceConnection? value) {
    _connection = value;
    if (value == null) {
      _disposePlugins();
      if (pairState != PairState.paired) {
        _instances.remove(info);
        notifier.close();
      }
    } else {
      _connection!.connectionListener = this;
      _initiatePlugins();
    }
    _notify();
  }

  late final _pairingHandler = PairingHandler(this, onStateChanged: (state) {});

  final List<UnisyncPlugin> plugins = [];

  BehaviorSubject<DeviceNotification> notifier = BehaviorSubject();

  bool get isOnline => _pairingHandler.isReady && connection != null;

  PairState get pairState => _pairingHandler.state;

  PairOperation get pairOperation => _pairingHandler;

  Future<void> _initiate() async {
    await _pairingHandler.initiate();
  }

  @override
  void onDisconnected() {
    connection = null;
  }

  @override
  void onMessage(DeviceMessage message) {
    if (message.type == DeviceMessage.Type.PAIR) {
      _pairingHandler.handle(message.body);
    } else if (_pairingHandler.state == PairState.paired) {
      for (final plugin in plugins) {
        if (plugin.type == message.type) {
          plugin.onReceive(message.body);
        }
      }
    }
  }

  void sendMessage(DeviceMessage message) {
    if (_pairingHandler.state == PairState.paired || message.type == DeviceMessage.Type.PAIR) {
      connection?.send(message);
    }
  }

  T getPlugin<T extends UnisyncPlugin>() {
    return plugins.firstWhere((element) => element is T) as T;
  }

  void _initiatePlugins() {
    plugins.addAll([
      BatteryPlugin(this),
      ClipboardPlugin(this),
      NotificationPlugin(this),
      VolumePlugin(this),
      RunCommandPlugin(this),
      RingPhonePlugin(this),
    ]);
  }

  void _disposePlugins() {
    for (final plugin in plugins) {
      plugin.dispose();
    }
    plugins.clear();
  }

  void _notify() {
    DeviceProvider.providerNotify();
    notifier.add(DeviceNotification(
      connected: isOnline,
      pairState: pairState,
    ));
  }
}

class DeviceNotification {
  DeviceNotification({
    this.connected = true,
    this.pairState = PairState.unknown,
  });

  final bool connected;
  final PairState pairState;
}
