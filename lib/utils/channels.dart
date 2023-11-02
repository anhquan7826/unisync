// ignore_for_file: constant_identifier_names

import 'package:flutter/services.dart';
import 'package:unisync/models/channel_result/channel_result.model.dart';
import 'package:unisync/utils/logger.dart';

class UnisyncChannels {
  UnisyncChannels._();

  static const _authority = 'com.anhquan.unisync.channel';

  static final connection = PairingChannel._();
  static final preferences = PreferencesChannel._();
}

abstract class _ChannelHandler {
  _ChannelHandler(this._methodChannel) {
    _methodChannel.setMethodCallHandler((call) {
      return _callHandlers[call.method]?.call((call.arguments as Map).cast<String, dynamic>());
    });
  }

  final MethodChannel _methodChannel;
  final _callHandlers = <String, dynamic Function(Map<String, dynamic>? arguments)>{};

  Future<ChannelResult> invokeMethod(String method, {Map<String, dynamic>? arguments}) async {
    final result = (await _methodChannel.invokeMethod<Map>(method, arguments))!.cast<String, dynamic>();
    debugLog('Invoke method channel finished with result:');
    debugLog(result);
    return ChannelResult.fromJson(result);
  }

  void addCallHandler(String call, void Function(Map<String, dynamic>? arguments) handler) {
    _callHandlers[call] = handler;
  }

  void removeHandler(String call) {
    _callHandlers.remove(call);
  }
}

class PairingChannel extends _ChannelHandler {
  PairingChannel._() : super(const MethodChannel('${UnisyncChannels._authority}/pairing'));
  static const GET_CONNECTED_DEVICES = 'get_connected_devices';
  static const GET_PAIRED_DEVICES = 'get_paired_devices';
  static const GET_UNPAIRED_DEVICES = 'get_unpaired_devices';

  /// Argument format is:
  /// {
  ///   "device": {
  ///     "id": _id,
  ///     "name": _name,
  ///     ...
  ///   }
  /// }
  /// with value of "device" is DeviceInfo converted to map.
  static const IS_DEVICE_ONLINE = 'is_device_online';

  /// Argument format is:
  /// {
  ///   "device": {
  ///     "id": _id,
  ///     "name": _name,
  ///     ...
  ///   }
  /// }
  /// with value of "device" is DeviceInfo converted to map.
  static const IS_DEVICE_PAIRED = 'is_device_paired';

  /// Argument format is:
  /// {
  ///   "device": {
  ///     "id": _id,
  ///     "name": _name,
  ///     ...
  ///   }
  /// }
  /// with value of "device" is DeviceInfo converted to map.
  static const ON_DEVICE_CONNECTED = 'on_device_connected';

  /// Argument format is:
  /// {
  ///   "device": {
  ///     "id": _id,
  ///     "name": _name,
  ///     ...
  ///   }
  /// }
  /// with value of "device" is DeviceInfo converted to map.
  static const ON_DEVICE_DISCONNECTED = 'on_device_disconnected';
}

class PreferencesChannel extends _ChannelHandler {
  PreferencesChannel._() : super(const MethodChannel('${UnisyncChannels._authority}/preferences'));
  static const PUT_STRING = 'put_string';
  static const PUT_INT = 'put_int';
  static const PUT_BOOL = 'put_bool';
  static const GET_STRING = 'get_string';
  static const GET_INT = 'get_int';
  static const GET_BOOL = 'get_bool';
}
