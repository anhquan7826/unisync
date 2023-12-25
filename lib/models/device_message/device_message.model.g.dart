// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_message.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceMessage _$DeviceMessageFromJson(Map<String, dynamic> json) =>
    DeviceMessage(
      fromDeviceId: json['fromDeviceId'] as String,
      toDeviceId: json['toDeviceId'] as String,
      plugin: json['plugin'] as String,
      function: json['function'] as String,
      extra: json['extra'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DeviceMessageToJson(DeviceMessage instance) =>
    <String, dynamic>{
      'fromDeviceId': instance.fromDeviceId,
      'toDeviceId': instance.toDeviceId,
      'plugin': instance.plugin,
      'function': instance.function,
      'extra': instance.extra,
    };
