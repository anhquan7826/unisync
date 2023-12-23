// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'device_message.model.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class DeviceMessage {
  DeviceMessage({
    required this.deviceId,
    required this.plugin,
    required this.function,
    this.extra = const {},
  });

  factory DeviceMessage.fromJson(Map<String, dynamic> json) => _$DeviceMessageFromJson(json);

  final String deviceId;
  final String plugin;
  final String function;
  final Map<String, dynamic> extra;
  Map<String, dynamic> toJson() => _$DeviceMessageToJson(this);
}
