import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/models/notification_data/notification_data.model.dart';

part 'notification.state.freezed.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default(null) Device? device,
    @Default(false) bool isOnline,
    @Default([]) List<NotificationData> notifications,
  }) = _NotificationState;
}
