// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => DeviceInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      ip: json['ip'] as String? ?? '',
      publicKey: json['publicKey'] as String? ?? '',
      deviceType: json['deviceType'] as String,
    );

Map<String, dynamic> _$DeviceInfoToJson(DeviceInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ip': instance.ip,
      'publicKey': instance.publicKey,
      'deviceType': instance.deviceType,
    };
