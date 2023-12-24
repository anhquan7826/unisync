// ignore_for_file: constant_identifier_names

import 'package:flutter/services.dart';
import 'package:unisync/models/channel_result/channel_result.model.dart';
import 'package:unisync/utils/logger.dart';

class UnisyncChannels {
  UnisyncChannels._();

  static const _authority = 'com.anhquan.unisync.channel';

  static final connection = ConnectionChannel._();
  static final pairing = PairingChannel._();
  static final preferences = PreferencesChannel._();
}

abstract class _ChannelHandler {
  _ChannelHandler(this._methodChannel) {
    _methodChannel.setMethodCallHandler((call) async {
      debugLog('Native invoked method ${call.method} with arguments ${call.arguments}');
      final args = (call.arguments as Map?)?.map((key, value) => MapEntry(key.toString(), value));
      return _callHandlers[call.method]?.call(args).toJson();
    });
  }

  final MethodChannel _methodChannel;
  final _callHandlers = <String, ChannelResult Function(Map<String, dynamic>? arguments)>{};

  Future<ChannelResult> invoke(String method, {Map<String, dynamic>? arguments}) async {
    debugLog('Invoking method $method...');
    final result = (await _methodChannel.invokeMethod<Map>(method, arguments))!.cast<String, dynamic>();
    debugLog('Result from method $method: $result');
    return ChannelResult.fromJson(result);
  }

  void addCallHandler(String call, ChannelResult Function(Map<String, dynamic>? arguments) handler) {
    _callHandlers[call] = handler;
  }

  void removeHandler(String call) {
    _callHandlers.remove(call);
  }
}

class ConnectionChannel extends _ChannelHandler {
  ConnectionChannel._() : super(const MethodChannel('${UnisyncChannels._authority}/connection'));

  static const GET_CONNECTED_DEVICES = 'get_connected_devices';

  /// Argument:
  /// {
  ///   "ip": _ipAddress
  /// }
  static const ADD_DEVICE_MANUALLY = 'add_device_manually';

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

class PairingChannel extends _ChannelHandler {
  PairingChannel._() : super(const MethodChannel('${UnisyncChannels._authority}/pairing'));
  static const GET_PAIRED_DEVICES = 'get_paired_devices';

  /// Argument:
  /// {
  ///   "id": _id
  /// }
  static const SET_ACCEPT_PAIR = 'set_accept_pair';

  /// Argument:
  /// {
  ///   "id": _id
  /// }
  static const SET_REJECT_PAIR = 'set_reject_pair';

  /// Argument:
  /// {
  ///   "id": _id,
  /// }
  static const ON_DEVICE_PAIR_REQUEST = 'on_device_pair_request';

  /// Argument:
  /// {
  ///   "id": _id,
  ///   "response": true|false
  /// }
  static const ON_DEVICE_PAIR_RESPONSE = 'on_device_pair_response';

  static const SEND_PAIR_REQUEST = 'send_pair_request';
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
