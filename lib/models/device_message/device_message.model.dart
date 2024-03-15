// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'device_message.model.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class DeviceMessage {
  DeviceMessage({required this.type, required this.body});

  factory DeviceMessage.fromJson(Map<String, dynamic> json) => _$DeviceMessageFromJson(json);

  final int time = DateTime.now().millisecondsSinceEpoch;
  final String type;
  final Map<String, dynamic> body;

  Map<String, dynamic> toJson() => _$DeviceMessageToJson(this);

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
