import 'package:json_annotation/json_annotation.dart';

part 'device_info.model.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class DeviceInfo {
  DeviceInfo({
    required this.deviceId,
    required this.deviceType,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => _$DeviceInfoFromJson(json);

  final String deviceId;
  final String deviceType;
  Map<String, dynamic> toJson() => _$DeviceInfoToJson(this);
}
