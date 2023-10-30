// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:unisync/constants/message_types.dart';

part 'device_request.model.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class DeviceRequest {
  DeviceRequest({
    required this.request,
    this.extras = const {},
  });

  factory DeviceRequest.fromJson(Map<String, dynamic> json) => _$DeviceRequestFromJson(json);

  final String type = MessageTypes.request;
  final int request;
  final Map<String, dynamic> extras;
  Map<String, dynamic> toJson() => _$DeviceRequestToJson(this);

  static const REQUEST_PAIR = 0;
}
