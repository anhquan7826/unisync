import 'package:rxdart/rxdart.dart';
import 'package:unisync/core/pairing_handler.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/core/plugins/battery.plugin.dart';
import 'package:unisync/core/plugins/clipboard.plugin.dart';
import 'package:unisync/core/plugins/notification_plugin.dart';
import 'package:unisync/core/plugins/ring_phone.plugin.dart';
import 'package:unisync/core/plugins/run_command.plugin.dart';
import 'package:unisync/core/plugins/volume.plugin.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/logger.dart';

import '../models/device_info/device_info.model.dart';
import '../models/device_message/device_message.model.dart';
import 'device_connection.dart';

class DeviceInstanceNotifyValue {
  DeviceInstanceNotifyValue({required this.added, required this.instance});

  final bool added;
  final Device instance;
}

class Device with ConnectionListener {
  factory Device(DeviceInfo info) {
    if (_instances.containsKey(info)) {
      return _instances[info]!;
    }
    _instances[info] = Device._(info);
    _instanceNotifier.add(DeviceInstanceNotifyValue(
      added: true,
      instance: _instances[info]!,
    ));
    return _instances[info]!;
  }

  factory Device.fromId(String id) {
    return _instances[DeviceInfo(id: id, name: '', deviceType: '')]!;
  }

  Device._(this.info) {
    _initiate();
  }

  static final Map<DeviceInfo, Device> _instances = {};
  static final _instanceNotifier = PublishSubject<DeviceInstanceNotifyValue>();

  static Stream<DeviceInstanceNotifyValue> get instanceNotifier => _instanceNotifier.asBroadcastStream();

  static void _removeInstance(DeviceInfo info) {
    final instance = _instances.remove(info);
    if (instance != null) {
      _instanceNotifier.add(DeviceInstanceNotifyValue(
        added: false,
        instance: instance,
      ));
    }
  }

  static Future<List<Device>> getAllDevices() async {
    for (final element in await ConfigUtil.device.getAllPairedDevices()) {
      Device(element);
    }
    return _instances.values.toList();
  }

  final DeviceInfo info;

  String? get ipAddress => _connection?.ipAddress;
  DeviceConnection? _connection;

  DeviceConnection? get connection => _connection;

  set connection(DeviceConnection? value) {
    _connection = value;
    if (value == null) {
      if (pairState != PairState.paired) {
        _removeInstance(info);
      }
      infoLog('Device@${info.name}: Disconnected!');
    } else {
      _connection!.connectionListener = this;
      infoLog('Device@${info.name}: Connected!');
    }
    _notify();
  }

  late final _pairingHandler = PairingHandler(this, onStateChanged: (state) {
    _notify();
  });

  final List<UnisyncPlugin> plugins = [];

  final BehaviorSubject<DeviceNotification> _notifier = BehaviorSubject();

  Stream<DeviceNotification> get notifier => _notifier.asBroadcastStream();

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
    infoLog('Device@${info.name}: Message received:');
    infoLog(message.toJson());
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
      infoLog('Device@${info.name}: Message sent:');
      infoLog(message.toJson());
    }
  }

  T getPlugin<T extends UnisyncPlugin>() {
    return plugins.firstWhere((element) => element is T) as T;
  }

  void _initiatePlugins() {
    plugins.addAll([
      StatusPlugin(this),
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
    debugLog('isOnline: $isOnline\npairState: $pairState');
    _notifier.add(DeviceNotification(
      connected: isOnline,
      pairState: pairState,
    ));
    if (isOnline && pairState == PairState.paired) {
      _initiatePlugins();
    } else {
      _disposePlugins();
    }
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
