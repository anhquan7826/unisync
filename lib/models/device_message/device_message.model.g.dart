// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_message.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceMessageImpl _$$DeviceMessageImplFromJson(Map<String, dynamic> json) =>
    _$DeviceMessageImpl(
      time: json['time'] as int,
      type: json['type'] as String,
      payload: json['payload'] == null
          ? null
          : DeviceMessagePayload.fromJson(
              json['payload'] as Map<String, dynamic>),
      body: json['body'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$DeviceMessageImplToJson(_$DeviceMessageImpl instance) =>
    <String, dynamic>{
      'time': instance.time,
      'type': instance.type,
      'payload': instance.payload,
      'body': instance.body,
    };

_$DeviceMessagePayloadImpl _$$DeviceMessagePayloadImplFromJson(
        Map<String, dynamic> json) =>
    _$DeviceMessagePayloadImpl(
      port: json['port'] as int,
      size: json['size'] as int,
    );

Map<String, dynamic> _$$DeviceMessagePayloadImplToJson(
        _$DeviceMessagePayloadImpl instance) =>
    <String, dynamic>{
      'port': instance.port,
      'size': instance.size,
    };
