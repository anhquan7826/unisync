// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'device_response.model.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class DeviceResponse {
  DeviceResponse({
    required this.request,
    required this.result,
    this.data = const {},
  });

  factory DeviceResponse.fromJson(Map<String, dynamic> json) => _$DeviceResponseFromJson(json);

  final int request;
  final int result;
  final Map<String, dynamic> data;
  Map<String, dynamic> toJson() => _$DeviceResponseToJson(this);

  static const RESPONSE_OK = 0;
  static const RESPONSE_NOK = 1;
}
