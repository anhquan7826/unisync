// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'device_message.model.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class DeviceMessage {
  DeviceMessage({
    required this.fromDeviceId,
    required this.toDeviceId,
    required this.plugin,
    required this.function,
    this.extra = const {},
  });

  factory DeviceMessage.fromJson(Map<String, dynamic> json) => _$DeviceMessageFromJson(json);

  final String fromDeviceId;
  final String toDeviceId;
  final String plugin;
  final String function;
  final Map<String, dynamic> extra;

  Map<String, dynamic> toJson() => _$DeviceMessageToJson(this);

  static const Pairing = (
    REQUEST_PAIR: 'request_pair',
    PAIR_ACCEPTED: 'pair_accepted',
    PAIR_REJECTED: 'pair_rejected',
    QUERY_PAIR: 'query_pair',
    UNPAIR: 'unpair',
  );

  DeviceMessage copy({
    String? fromDeviceId,
    String? toDeviceId,
    String? plugin,
    String? function,
    Map<String, dynamic>? extra,
  }) {
    return DeviceMessage(
      fromDeviceId: fromDeviceId ?? this.fromDeviceId,
      toDeviceId: toDeviceId ?? this.toDeviceId,
      plugin: plugin ?? this.plugin,
      function: function ?? this.function,
      extra: extra ?? this.extra,
    );
  }
}
