// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_request.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceRequest _$DeviceRequestFromJson(Map<String, dynamic> json) =>
    DeviceRequest(
      request: json['request'] as int,
      extras: json['extras'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DeviceRequestToJson(DeviceRequest instance) =>
    <String, dynamic>{
      'request': instance.request,
      'extras': instance.extras,
    };
