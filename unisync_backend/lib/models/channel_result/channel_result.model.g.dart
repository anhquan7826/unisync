// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_result.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelResult _$ChannelResultFromJson(Map<String, dynamic> json) =>
    ChannelResult(
      method: json['method'] as String,
      resultCode: json['resultCode'] as int,
      result: json['result'],
      error: json['error'] as String?,
    );

Map<String, dynamic> _$ChannelResultToJson(ChannelResult instance) =>
    <String, dynamic>{
      'method': instance.method,
      'resultCode': instance.resultCode,
      'result': instance.result,
      'error': instance.error,
    };
