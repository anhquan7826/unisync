// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home.state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$HomeState {
  int get timestamp => throw _privateConstructorUsedError;
  DeviceInfo? get myDevice => throw _privateConstructorUsedError;
  Device get currentDevice => throw _privateConstructorUsedError;
  List<Device> get pairedDevices => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call(
      {int timestamp,
      DeviceInfo? myDevice,
      Device currentDevice,
      List<Device> pairedDevices});
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? myDevice = freezed,
    Object? currentDevice = null,
    Object? pairedDevices = null,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      myDevice: freezed == myDevice
          ? _value.myDevice
          : myDevice // ignore: cast_nullable_to_non_nullable
              as DeviceInfo?,
      currentDevice: null == currentDevice
          ? _value.currentDevice
          : currentDevice // ignore: cast_nullable_to_non_nullable
              as Device,
      pairedDevices: null == pairedDevices
          ? _value.pairedDevices
          : pairedDevices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomeStateImplCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$$HomeStateImplCopyWith(
          _$HomeStateImpl value, $Res Function(_$HomeStateImpl) then) =
      __$$HomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int timestamp,
      DeviceInfo? myDevice,
      Device currentDevice,
      List<Device> pairedDevices});
}

/// @nodoc
class __$$HomeStateImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeStateImpl>
    implements _$$HomeStateImplCopyWith<$Res> {
  __$$HomeStateImplCopyWithImpl(
      _$HomeStateImpl _value, $Res Function(_$HomeStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? myDevice = freezed,
    Object? currentDevice = null,
    Object? pairedDevices = null,
  }) {
    return _then(_$HomeStateImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      myDevice: freezed == myDevice
          ? _value.myDevice
          : myDevice // ignore: cast_nullable_to_non_nullable
              as DeviceInfo?,
      currentDevice: null == currentDevice
          ? _value.currentDevice
          : currentDevice // ignore: cast_nullable_to_non_nullable
              as Device,
      pairedDevices: null == pairedDevices
          ? _value._pairedDevices
          : pairedDevices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
    ));
  }
}

/// @nodoc

class _$HomeStateImpl implements _HomeState {
  const _$HomeStateImpl(
      {required this.timestamp,
      this.myDevice = null,
      required this.currentDevice,
      final List<Device> pairedDevices = const []})
      : _pairedDevices = pairedDevices;

  @override
  final int timestamp;
  @override
  @JsonKey()
  final DeviceInfo? myDevice;
  @override
  final Device currentDevice;
  final List<Device> _pairedDevices;
  @override
  @JsonKey()
  List<Device> get pairedDevices {
    if (_pairedDevices is EqualUnmodifiableListView) return _pairedDevices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pairedDevices);
  }

  @override
  String toString() {
    return 'HomeState(timestamp: $timestamp, myDevice: $myDevice, currentDevice: $currentDevice, pairedDevices: $pairedDevices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.myDevice, myDevice) ||
                other.myDevice == myDevice) &&
            (identical(other.currentDevice, currentDevice) ||
                other.currentDevice == currentDevice) &&
            const DeepCollectionEquality()
                .equals(other._pairedDevices, _pairedDevices));
  }

  @override
  int get hashCode => Object.hash(runtimeType, timestamp, myDevice,
      currentDevice, const DeepCollectionEquality().hash(_pairedDevices));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState implements HomeState {
  const factory _HomeState(
      {required final int timestamp,
      final DeviceInfo? myDevice,
      required final Device currentDevice,
      final List<Device> pairedDevices}) = _$HomeStateImpl;

  @override
  int get timestamp;
  @override
  DeviceInfo? get myDevice;
  @override
  Device get currentDevice;
  @override
  List<Device> get pairedDevices;
  @override
  @JsonKey(ignore: true)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
