import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_info.model.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
@immutable
class DeviceInfo {
  const DeviceInfo({
    required this.id,
    required this.name,
    required this.deviceType,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => _$DeviceInfoFromJson(json);

  final String id;
  final String name;
  final String deviceType;

  Map<String, dynamic> toJson() => _$DeviceInfoToJson(this);

  DeviceInfo copy({String? id, String? name, String? ip, String? publicKey, String? deviceType}) {
    return DeviceInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceType: deviceType ?? this.deviceType,
    );
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is DeviceInfo && id == other.id;
  }

  @override
  String toString() {
    return '$id:$name:$deviceType';
  }
}
