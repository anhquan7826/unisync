import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unisync/utils/constants/load_state.dart';

part 'status.state.freezed.dart';

@freezed
class StatusState with _$StatusState {
  const factory StatusState({
    @Default(LoadState.idle) LoadState loadState,
    @Default(-1) int batteryLevel,
    @Default(false) bool isCharging,
  }) = _StatusState;
}
