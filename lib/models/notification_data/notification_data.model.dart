import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_data.model.freezed.dart';

@freezed
class NotificationData with _$NotificationData {
  const factory NotificationData({
    required int timestamp,
    Uint8List? icon,
    required String appName,
    required String title,
    required String text,
    String? subText,
    String? bigText,
  }) = _NotificationData;
}
