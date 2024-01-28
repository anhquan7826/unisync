// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'channel_result.model.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class ChannelResult {
  ChannelResult({
    required this.method,
    required this.resultCode,
    this.result,
    this.error,
  });

  factory ChannelResult.fromJson(Map<String, dynamic> json) => _$ChannelResultFromJson(json);
  static const SUCCESS = 0;
  static const FAILED = -1;

  final String method;
  final int resultCode;
  final dynamic result;
  final String? error;

  Map<String, dynamic> toJson() => _$ChannelResultToJson(this);
}
