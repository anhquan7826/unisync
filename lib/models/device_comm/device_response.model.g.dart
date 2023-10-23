// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_response.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceResponse _$DeviceResponseFromJson(Map<String, dynamic> json) =>
    DeviceResponse(
      request: json['request'] as int,
      result: json['result'] as int,
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DeviceResponseToJson(DeviceResponse instance) =>
    <String, dynamic>{
      'request': instance.request,
      'result': instance.result,
      'data': instance.data,
    };
