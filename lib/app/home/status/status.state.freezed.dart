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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$StatusState {
  Device? get device => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  String? get ipAddress => throw _privateConstructorUsedError;
  int get batteryLevel => throw _privateConstructorUsedError;
  bool get isCharging => throw _privateConstructorUsedError;
  Uint8List? get wallpaper => throw _privateConstructorUsedError;

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
  $Res call(
      {Device? device,
      bool isOnline,
      String? ipAddress,
      int batteryLevel,
      bool isCharging,
      Uint8List? wallpaper});
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
    Object? device = freezed,
    Object? isOnline = null,
    Object? ipAddress = freezed,
    Object? batteryLevel = null,
    Object? isCharging = null,
    Object? wallpaper = freezed,
  }) {
    return _then(_value.copyWith(
      device: freezed == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as Device?,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      batteryLevel: null == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int,
      isCharging: null == isCharging
          ? _value.isCharging
          : isCharging // ignore: cast_nullable_to_non_nullable
              as bool,
      wallpaper: freezed == wallpaper
          ? _value.wallpaper
          : wallpaper // ignore: cast_nullable_to_non_nullable
              as Uint8List?,
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
  $Res call(
      {Device? device,
      bool isOnline,
      String? ipAddress,
      int batteryLevel,
      bool isCharging,
      Uint8List? wallpaper});
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
    Object? device = freezed,
    Object? isOnline = null,
    Object? ipAddress = freezed,
    Object? batteryLevel = null,
    Object? isCharging = null,
    Object? wallpaper = freezed,
  }) {
    return _then(_$StatusStateImpl(
      device: freezed == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as Device?,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      batteryLevel: null == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int,
      isCharging: null == isCharging
          ? _value.isCharging
          : isCharging // ignore: cast_nullable_to_non_nullable
              as bool,
      wallpaper: freezed == wallpaper
          ? _value.wallpaper
          : wallpaper // ignore: cast_nullable_to_non_nullable
              as Uint8List?,
    ));
  }
}

/// @nodoc

class _$StatusStateImpl implements _StatusState {
  const _$StatusStateImpl(
      {this.device = null,
      this.isOnline = false,
      this.ipAddress = null,
      this.batteryLevel = -1,
      this.isCharging = false,
      this.wallpaper = null});

  @override
  @JsonKey()
  final Device? device;
  @override
  @JsonKey()
  final bool isOnline;
  @override
  @JsonKey()
  final String? ipAddress;
  @override
  @JsonKey()
  final int batteryLevel;
  @override
  @JsonKey()
  final bool isCharging;
  @override
  @JsonKey()
  final Uint8List? wallpaper;

  @override
  String toString() {
    return 'StatusState(device: $device, isOnline: $isOnline, ipAddress: $ipAddress, batteryLevel: $batteryLevel, isCharging: $isCharging, wallpaper: $wallpaper)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatusStateImpl &&
            (identical(other.device, device) || other.device == device) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.batteryLevel, batteryLevel) ||
                other.batteryLevel == batteryLevel) &&
            (identical(other.isCharging, isCharging) ||
                other.isCharging == isCharging) &&
            const DeepCollectionEquality().equals(other.wallpaper, wallpaper));
  }

  @override
  int get hashCode => Object.hash(runtimeType, device, isOnline, ipAddress,
      batteryLevel, isCharging, const DeepCollectionEquality().hash(wallpaper));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StatusStateImplCopyWith<_$StatusStateImpl> get copyWith =>
      __$$StatusStateImplCopyWithImpl<_$StatusStateImpl>(this, _$identity);
}

abstract class _StatusState implements StatusState {
  const factory _StatusState(
      {final Device? device,
      final bool isOnline,
      final String? ipAddress,
      final int batteryLevel,
      final bool isCharging,
      final Uint8List? wallpaper}) = _$StatusStateImpl;

  @override
  Device? get device;
  @override
  bool get isOnline;
  @override
  String? get ipAddress;
  @override
  int get batteryLevel;
  @override
  bool get isCharging;
  @override
  Uint8List? get wallpaper;
  @override
  @JsonKey(ignore: true)
  _$$StatusStateImplCopyWith<_$StatusStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
