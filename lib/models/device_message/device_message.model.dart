// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_message.model.g.dart';
part 'device_message.model.freezed.dart';

@freezed
class DeviceMessage with _$DeviceMessage {
  factory DeviceMessage({
    required int time,
    required String type,
    DeviceMessagePayload? payload,
    @Default({}) Map<String, dynamic> body,
  }) = _DeviceMessage;

  factory DeviceMessage.fromJson(Map<String, dynamic> json) =>
      _$DeviceMessageFromJson(json);

  static const Type = (
    PAIR: 'pair',
    STATUS: 'status',
    CLIPBOARD: 'clipboard',
    NOTIFICATION: 'notification',
    VOLUME: 'volume',
    RUN_COMMAND: 'run_command',
    RING_PHONE: 'ring_phone',
    TELEPHONY: 'telephony',
  );
}

@freezed
class DeviceMessagePayload with _$DeviceMessagePayload {
  factory DeviceMessagePayload({
    required int port,
    required int size,
  }) = _DeviceMessagePayload;

  factory DeviceMessagePayload.fromJson(Map<String, dynamic> json) =>
      _$DeviceMessagePayloadFromJson(json);
}
