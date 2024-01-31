// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_message.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceMessage _$DeviceMessageFromJson(Map<String, dynamic> json) =>
    DeviceMessage(
      type: json['type'] as String,
      body: json['body'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DeviceMessageToJson(DeviceMessage instance) =>
    <String, dynamic>{
      'type': instance.type,
      'body': instance.body,
    };
