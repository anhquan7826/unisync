// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_message.model.g.dart';

part 'device_message.model.freezed.dart';

@freezed
class DeviceMessage with _$DeviceMessage {
  factory DeviceMessage({
    required int time,
    required String type,
    required DeviceMessageHeader header,
    DeviceMessagePayload? payload,
    @Default({}) Map<String, dynamic> body,
  }) = _DeviceMessage;

  factory DeviceMessage.fromJson(Map<String, dynamic> json) =>
      _$DeviceMessageFromJson(json);

  static const BodyKey = (
    ERROR: 'error',
  );

  static const Type = (
    PAIR: 'pair',
    STATUS: 'status',
    CLIPBOARD: 'clipboard',
    NOTIFICATION: 'notification',
    VOLUME: 'volume',
    RUN_COMMAND: 'run_command',
    RING_PHONE: 'ring_phone',
    TELEPHONY: 'telephony',
    SHARING: 'sharing',
    GALLERY: 'gallery',
    STORAGE: 'storage',
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

@freezed
class DeviceMessageHeader with _$DeviceMessageHeader {
  const factory DeviceMessageHeader({
    required String type,
    required String method,
    String? status,
  }) = _DeviceMessageHeader;

  factory DeviceMessageHeader.fromJson(Map<String, dynamic> json) =>
      _$DeviceMessageHeaderFromJson(json);

  static const Type = (
    REQUEST: 'request',
    RESPONSE: 'response',
    NOTIFICATION: 'notification',
  );

  static const Status = (
    SUCCESS: 'success',
    ERROR: 'error',
  );
}
