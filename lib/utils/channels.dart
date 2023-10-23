import 'package:flutter/services.dart';
import 'package:unisync/models/channel_result/channel_result.model.dart';
import 'package:unisync/utils/logger.dart';

class UnisyncChannels {
  UnisyncChannels._();

  static const _authority = 'com.anhquan.unisync.channel';

  static final connection = ConnectionChannel();
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

class ConnectionChannel extends _ChannelHandler {
  ConnectionChannel() : super(const MethodChannel('${UnisyncChannels._authority}/pairing'));
  static const nativeGetDiscoveredDevices = 'get_discovered_devices';
}
