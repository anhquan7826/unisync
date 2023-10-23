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

  DeviceInfo copy({String? id, String? name, String? ip, String? publicKey, String? deviceType}) {
    return DeviceInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      publicKey: publicKey ?? this.publicKey,
      deviceType: deviceType ?? this.deviceType,
    );
  }
}
