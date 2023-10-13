import 'package:json_annotation/json_annotation.dart';

part 'device_info.model.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class DeviceInfo {
  DeviceInfo({
    required this.id,
    required this.name,
    this.ip = '',
    this.publicKey = '',
    required this.deviceType,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => _$DeviceInfoFromJson(json);

  final String id;
  final String name;
  final String ip;
  final String publicKey;
  final String deviceType;
  Map<String, dynamic> toJson() => _$DeviceInfoToJson(this);
}
