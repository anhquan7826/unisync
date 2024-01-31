// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status.state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$StatusState {
  LoadState get loadState => throw _privateConstructorUsedError;
  int get batteryLevel => throw _privateConstructorUsedError;
  bool get isCharging => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $StatusStateCopyWith<StatusState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatusStateCopyWith<$Res> {
  factory $StatusStateCopyWith(
          StatusState value, $Res Function(StatusState) then) =
      _$StatusStateCopyWithImpl<$Res, StatusState>;
  @useResult
  $Res call({LoadState loadState, int batteryLevel, bool isCharging});
}

/// @nodoc
class _$StatusStateCopyWithImpl<$Res, $Val extends StatusState>
    implements $StatusStateCopyWith<$Res> {
  _$StatusStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loadState = null,
    Object? batteryLevel = null,
    Object? isCharging = null,
  }) {
    return _then(_value.copyWith(
      loadState: null == loadState
          ? _value.loadState
          : loadState // ignore: cast_nullable_to_non_nullable
              as LoadState,
      batteryLevel: null == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int,
      isCharging: null == isCharging
          ? _value.isCharging
          : isCharging // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StatusStateImplCopyWith<$Res>
    implements $StatusStateCopyWith<$Res> {
  factory _$$StatusStateImplCopyWith(
          _$StatusStateImpl value, $Res Function(_$StatusStateImpl) then) =
      __$$StatusStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({LoadState loadState, int batteryLevel, bool isCharging});
}

/// @nodoc
class __$$StatusStateImplCopyWithImpl<$Res>
    extends _$StatusStateCopyWithImpl<$Res, _$StatusStateImpl>
    implements _$$StatusStateImplCopyWith<$Res> {
  __$$StatusStateImplCopyWithImpl(
      _$StatusStateImpl _value, $Res Function(_$StatusStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loadState = null,
    Object? batteryLevel = null,
    Object? isCharging = null,
  }) {
    return _then(_$StatusStateImpl(
      loadState: null == loadState
          ? _value.loadState
          : loadState // ignore: cast_nullable_to_non_nullable
              as LoadState,
      batteryLevel: null == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int,
      isCharging: null == isCharging
          ? _value.isCharging
          : isCharging // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$StatusStateImpl implements _StatusState {
  const _$StatusStateImpl(
      {this.loadState = LoadState.idle,
      this.batteryLevel = -1,
      this.isCharging = false});

  @override
  @JsonKey()
  final LoadState loadState;
  @override
  @JsonKey()
  final int batteryLevel;
  @override
  @JsonKey()
  final bool isCharging;

  @override
  String toString() {
    return 'StatusState(loadState: $loadState, batteryLevel: $batteryLevel, isCharging: $isCharging)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatusStateImpl &&
            (identical(other.loadState, loadState) ||
                other.loadState == loadState) &&
            (identical(other.batteryLevel, batteryLevel) ||
                other.batteryLevel == batteryLevel) &&
            (identical(other.isCharging, isCharging) ||
                other.isCharging == isCharging));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, loadState, batteryLevel, isCharging);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StatusStateImplCopyWith<_$StatusStateImpl> get copyWith =>
      __$$StatusStateImplCopyWithImpl<_$StatusStateImpl>(this, _$identity);
}

abstract class _StatusState implements StatusState {
  const factory _StatusState(
      {final LoadState loadState,
      final int batteryLevel,
      final bool isCharging}) = _$StatusStateImpl;

  @override
  LoadState get loadState;
  @override
  int get batteryLevel;
  @override
  bool get isCharging;
  @override
  @JsonKey(ignore: true)
  _$$StatusStateImplCopyWith<_$StatusStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
