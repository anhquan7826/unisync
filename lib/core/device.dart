import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:unisync/core/pairing_handler.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/core/plugins/clipboard/clipboard.plugin.dart';
import 'package:unisync/core/plugins/gallery/gallery.plugin.dart';
import 'package:unisync/core/plugins/notification/notification_plugin.dart';
import 'package:unisync/core/plugins/ring_phone/ring_phone.plugin.dart';
import 'package:unisync/core/plugins/run_command/run_command.plugin.dart';
import 'package:unisync/core/plugins/sharing/sharing.plugin.dart';
import 'package:unisync/core/plugins/status/status.plugin.dart';
import 'package:unisync/core/plugins/storage/storage.plugin.dart';
import 'package:unisync/core/plugins/telephony/telephony.plugin.dart';
import 'package:unisync/core/plugins/volume/volume.plugin.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/logger.dart';
import 'package:unisync/utils/push_notification.dart';

import '../models/device_info/device_info.model.dart';
import '../models/device_message/device_message.model.dart';
import 'device_connection.dart';

class Device with ConnectionListener {
  factory Device(DeviceInfo info) {
    if (_instances.containsKey(info)) {
      return _instances[info]!;
    }
    _instances[info] = Device._(info);
    debugLog('Created an instance of Device.');
    _instanceNotifier.add(_instances.values.toList());
    debugLog('Device instances notified.');
    return _instances[info]!;
  }

  factory Device.fromId(String id) {
    return _instances[DeviceInfo(id: id, name: '', deviceType: '')]!;
  }

  Device._(this.info) {
    _initiate();
  }

  static final Map<DeviceInfo, Device> _instances = {};
  static final _instanceNotifier = BehaviorSubject<List<Device>>();

  static Stream<List<Device>> get instanceNotifier =>
      _instanceNotifier.asBroadcastStream();

  static void _removeInstance(DeviceInfo info) {
    final instance = _instances.remove(info);
    if (instance != null) {
      _instanceNotifier.add(_instances.values.toList());
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
      if (pairState == PairState.markUnpaired) {
        pairOperation.unpair();
      }
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
  void onMessage(DeviceMessage message, Payload? payload) {
    infoLog('Device@${info.name}: Message received:');
    infoLog(message.toJson());
    if (message.type == DeviceMessage.Type.PAIR) {
      _pairingHandler.handle(message.body);
    } else if (_pairingHandler.state == PairState.paired) {
      for (final plugin in plugins) {
        if (plugin.type == message.type) {
          plugin.onReceive(message.header, message.body, payload);
        }
      }
    }
  }

  void sendMessage(DeviceMessage message, [Uint8List? data]) {
    if (_pairingHandler.state == PairState.paired ||
        message.type == DeviceMessage.Type.PAIR) {
      connection?.send(message, data);
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
      TelephonyPlugin(this),
      SharingPlugin(this),
      GalleryPlugin(this),
      StoragePlugin(this),
    ]);
  }

  void _disposePlugins() {
    for (final plugin in plugins) {
      plugin.dispose();
    }
    plugins.clear();
  }

  void showNotification() {
    if (pairState == PairState.paired) {
      if (isOnline) {
        PushNotification.showNotification(
          title: 'Connection',
          text: 'Device ${info.name} connected!',
        );
      } else {
        PushNotification.showNotification(
          title: 'Connection',
          text: 'Device ${info.name} disconnected!',
        );
      }
    } else if (pairState == PairState.pairRequested) {
      PushNotification.showNotification(
        title: 'Pairing',
        text: 'Device ${info.name} requests to pair!',
      );
    }
  }

  void _notify() {
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
