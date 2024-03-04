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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$DeviceConnectionState {
  Status get status => throw _privateConstructorUsedError;
  Set<DeviceInfo> get availableDevices => throw _privateConstructorUsedError;
  Set<DeviceInfo> get pairedDevices => throw _privateConstructorUsedError;
  Set<DeviceInfo> get requestedDevices => throw _privateConstructorUsedError;

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
      {Status status,
      Set<DeviceInfo> availableDevices,
      Set<DeviceInfo> pairedDevices,
      Set<DeviceInfo> requestedDevices});
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
    Object? status = null,
    Object? availableDevices = null,
    Object? pairedDevices = null,
    Object? requestedDevices = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as Status,
      availableDevices: null == availableDevices
          ? _value.availableDevices
          : availableDevices // ignore: cast_nullable_to_non_nullable
              as Set<DeviceInfo>,
      pairedDevices: null == pairedDevices
          ? _value.pairedDevices
          : pairedDevices // ignore: cast_nullable_to_non_nullable
              as Set<DeviceInfo>,
      requestedDevices: null == requestedDevices
          ? _value.requestedDevices
          : requestedDevices // ignore: cast_nullable_to_non_nullable
              as Set<DeviceInfo>,
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
      {Status status,
      Set<DeviceInfo> availableDevices,
      Set<DeviceInfo> pairedDevices,
      Set<DeviceInfo> requestedDevices});
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
    Object? status = null,
    Object? availableDevices = null,
    Object? pairedDevices = null,
    Object? requestedDevices = null,
  }) {
    return _then(_$DeviceConnectionStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as Status,
      availableDevices: null == availableDevices
          ? _value._availableDevices
          : availableDevices // ignore: cast_nullable_to_non_nullable
              as Set<DeviceInfo>,
      pairedDevices: null == pairedDevices
          ? _value._pairedDevices
          : pairedDevices // ignore: cast_nullable_to_non_nullable
              as Set<DeviceInfo>,
      requestedDevices: null == requestedDevices
          ? _value._requestedDevices
          : requestedDevices // ignore: cast_nullable_to_non_nullable
              as Set<DeviceInfo>,
    ));
  }
}

/// @nodoc

class _$DeviceConnectionStateImpl implements _DeviceConnectionState {
  const _$DeviceConnectionStateImpl(
      {this.status = Status.loading,
      final Set<DeviceInfo> availableDevices = const {},
      final Set<DeviceInfo> pairedDevices = const {},
      final Set<DeviceInfo> requestedDevices = const {}})
      : _availableDevices = availableDevices,
        _pairedDevices = pairedDevices,
        _requestedDevices = requestedDevices;

  @override
  @JsonKey()
  final Status status;
  final Set<DeviceInfo> _availableDevices;
  @override
  @JsonKey()
  Set<DeviceInfo> get availableDevices {
    if (_availableDevices is EqualUnmodifiableSetView) return _availableDevices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_availableDevices);
  }

  final Set<DeviceInfo> _pairedDevices;
  @override
  @JsonKey()
  Set<DeviceInfo> get pairedDevices {
    if (_pairedDevices is EqualUnmodifiableSetView) return _pairedDevices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_pairedDevices);
  }

  final Set<DeviceInfo> _requestedDevices;
  @override
  @JsonKey()
  Set<DeviceInfo> get requestedDevices {
    if (_requestedDevices is EqualUnmodifiableSetView) return _requestedDevices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_requestedDevices);
  }

  @override
  String toString() {
    return 'DeviceConnectionState(status: $status, availableDevices: $availableDevices, pairedDevices: $pairedDevices, requestedDevices: $requestedDevices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceConnectionStateImpl &&
            (identical(other.status, status) || other.status == status) &&
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
      status,
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
      {final Status status,
      final Set<DeviceInfo> availableDevices,
      final Set<DeviceInfo> pairedDevices,
      final Set<DeviceInfo> requestedDevices}) = _$DeviceConnectionStateImpl;

  @override
  Status get status;
  @override
  Set<DeviceInfo> get availableDevices;
  @override
  Set<DeviceInfo> get pairedDevices;
  @override
  Set<DeviceInfo> get requestedDevices;
  @override
  @JsonKey(ignore: true)
  _$$DeviceConnectionStateImplCopyWith<_$DeviceConnectionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
