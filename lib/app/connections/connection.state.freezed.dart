// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection.state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DeviceConnectionState {
  List<Device> get availableDevices => throw _privateConstructorUsedError;
  List<Device> get pairedDevices => throw _privateConstructorUsedError;
  List<Device> get requestedDevices => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DeviceConnectionStateCopyWith<DeviceConnectionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceConnectionStateCopyWith<$Res> {
  factory $DeviceConnectionStateCopyWith(DeviceConnectionState value,
          $Res Function(DeviceConnectionState) then) =
      _$DeviceConnectionStateCopyWithImpl<$Res, DeviceConnectionState>;
  @useResult
  $Res call(
      {List<Device> availableDevices,
      List<Device> pairedDevices,
      List<Device> requestedDevices});
}

/// @nodoc
class _$DeviceConnectionStateCopyWithImpl<$Res,
        $Val extends DeviceConnectionState>
    implements $DeviceConnectionStateCopyWith<$Res> {
  _$DeviceConnectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? availableDevices = null,
    Object? pairedDevices = null,
    Object? requestedDevices = null,
  }) {
    return _then(_value.copyWith(
      availableDevices: null == availableDevices
          ? _value.availableDevices
          : availableDevices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
      pairedDevices: null == pairedDevices
          ? _value.pairedDevices
          : pairedDevices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
      requestedDevices: null == requestedDevices
          ? _value.requestedDevices
          : requestedDevices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeviceConnectionStateImplCopyWith<$Res>
    implements $DeviceConnectionStateCopyWith<$Res> {
  factory _$$DeviceConnectionStateImplCopyWith(
          _$DeviceConnectionStateImpl value,
          $Res Function(_$DeviceConnectionStateImpl) then) =
      __$$DeviceConnectionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Device> availableDevices,
      List<Device> pairedDevices,
      List<Device> requestedDevices});
}

/// @nodoc
class __$$DeviceConnectionStateImplCopyWithImpl<$Res>
    extends _$DeviceConnectionStateCopyWithImpl<$Res,
        _$DeviceConnectionStateImpl>
    implements _$$DeviceConnectionStateImplCopyWith<$Res> {
  __$$DeviceConnectionStateImplCopyWithImpl(_$DeviceConnectionStateImpl _value,
      $Res Function(_$DeviceConnectionStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? availableDevices = null,
    Object? pairedDevices = null,
    Object? requestedDevices = null,
  }) {
    return _then(_$DeviceConnectionStateImpl(
      availableDevices: null == availableDevices
          ? _value._availableDevices
          : availableDevices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
      pairedDevices: null == pairedDevices
          ? _value._pairedDevices
          : pairedDevices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
      requestedDevices: null == requestedDevices
          ? _value._requestedDevices
          : requestedDevices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
    ));
  }
}

/// @nodoc

class _$DeviceConnectionStateImpl implements _DeviceConnectionState {
  const _$DeviceConnectionStateImpl(
      {final List<Device> availableDevices = const [],
      final List<Device> pairedDevices = const [],
      final List<Device> requestedDevices = const []})
      : _availableDevices = availableDevices,
        _pairedDevices = pairedDevices,
        _requestedDevices = requestedDevices;

  final List<Device> _availableDevices;
  @override
  @JsonKey()
  List<Device> get availableDevices {
    if (_availableDevices is EqualUnmodifiableListView)
      return _availableDevices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableDevices);
  }

  final List<Device> _pairedDevices;
  @override
  @JsonKey()
  List<Device> get pairedDevices {
    if (_pairedDevices is EqualUnmodifiableListView) return _pairedDevices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pairedDevices);
  }

  final List<Device> _requestedDevices;
  @override
  @JsonKey()
  List<Device> get requestedDevices {
    if (_requestedDevices is EqualUnmodifiableListView)
      return _requestedDevices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requestedDevices);
  }

  @override
  String toString() {
    return 'DeviceConnectionState(availableDevices: $availableDevices, pairedDevices: $pairedDevices, requestedDevices: $requestedDevices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceConnectionStateImpl &&
            const DeepCollectionEquality()
                .equals(other._availableDevices, _availableDevices) &&
            const DeepCollectionEquality()
                .equals(other._pairedDevices, _pairedDevices) &&
            const DeepCollectionEquality()
                .equals(other._requestedDevices, _requestedDevices));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_availableDevices),
      const DeepCollectionEquality().hash(_pairedDevices),
      const DeepCollectionEquality().hash(_requestedDevices));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceConnectionStateImplCopyWith<_$DeviceConnectionStateImpl>
      get copyWith => __$$DeviceConnectionStateImplCopyWithImpl<
          _$DeviceConnectionStateImpl>(this, _$identity);
}

abstract class _DeviceConnectionState implements DeviceConnectionState {
  const factory _DeviceConnectionState(
      {final List<Device> availableDevices,
      final List<Device> pairedDevices,
      final List<Device> requestedDevices}) = _$DeviceConnectionStateImpl;

  @override
  List<Device> get availableDevices;
  @override
  List<Device> get pairedDevices;
  @override
  List<Device> get requestedDevices;
  @override
  @JsonKey(ignore: true)
  _$$DeviceConnectionStateImplCopyWith<_$DeviceConnectionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
