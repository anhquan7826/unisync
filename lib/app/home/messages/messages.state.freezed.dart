// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messages.state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$MessagesState {
  int get timestamp => throw _privateConstructorUsedError;
  Device? get device => throw _privateConstructorUsedError;
  Status get status => throw _privateConstructorUsedError;
  Conversation? get currentConversation => throw _privateConstructorUsedError;
  List<Conversation> get conversations => throw _privateConstructorUsedError;
  Message? get newMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MessagesStateCopyWith<MessagesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessagesStateCopyWith<$Res> {
  factory $MessagesStateCopyWith(
          MessagesState value, $Res Function(MessagesState) then) =
      _$MessagesStateCopyWithImpl<$Res, MessagesState>;
  @useResult
  $Res call(
      {int timestamp,
      Device? device,
      Status status,
      Conversation? currentConversation,
      List<Conversation> conversations,
      Message? newMessage});

  $ConversationCopyWith<$Res>? get currentConversation;
  $MessageCopyWith<$Res>? get newMessage;
}

/// @nodoc
class _$MessagesStateCopyWithImpl<$Res, $Val extends MessagesState>
    implements $MessagesStateCopyWith<$Res> {
  _$MessagesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? device = freezed,
    Object? status = null,
    Object? currentConversation = freezed,
    Object? conversations = null,
    Object? newMessage = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      device: freezed == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as Device?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as Status,
      currentConversation: freezed == currentConversation
          ? _value.currentConversation
          : currentConversation // ignore: cast_nullable_to_non_nullable
              as Conversation?,
      conversations: null == conversations
          ? _value.conversations
          : conversations // ignore: cast_nullable_to_non_nullable
              as List<Conversation>,
      newMessage: freezed == newMessage
          ? _value.newMessage
          : newMessage // ignore: cast_nullable_to_non_nullable
              as Message?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ConversationCopyWith<$Res>? get currentConversation {
    if (_value.currentConversation == null) {
      return null;
    }

    return $ConversationCopyWith<$Res>(_value.currentConversation!, (value) {
      return _then(_value.copyWith(currentConversation: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $MessageCopyWith<$Res>? get newMessage {
    if (_value.newMessage == null) {
      return null;
    }

    return $MessageCopyWith<$Res>(_value.newMessage!, (value) {
      return _then(_value.copyWith(newMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MessagesStateImplCopyWith<$Res>
    implements $MessagesStateCopyWith<$Res> {
  factory _$$MessagesStateImplCopyWith(
          _$MessagesStateImpl value, $Res Function(_$MessagesStateImpl) then) =
      __$$MessagesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int timestamp,
      Device? device,
      Status status,
      Conversation? currentConversation,
      List<Conversation> conversations,
      Message? newMessage});

  @override
  $ConversationCopyWith<$Res>? get currentConversation;
  @override
  $MessageCopyWith<$Res>? get newMessage;
}

/// @nodoc
class __$$MessagesStateImplCopyWithImpl<$Res>
    extends _$MessagesStateCopyWithImpl<$Res, _$MessagesStateImpl>
    implements _$$MessagesStateImplCopyWith<$Res> {
  __$$MessagesStateImplCopyWithImpl(
      _$MessagesStateImpl _value, $Res Function(_$MessagesStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? device = freezed,
    Object? status = null,
    Object? currentConversation = freezed,
    Object? conversations = null,
    Object? newMessage = freezed,
  }) {
    return _then(_$MessagesStateImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      device: freezed == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as Device?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as Status,
      currentConversation: freezed == currentConversation
          ? _value.currentConversation
          : currentConversation // ignore: cast_nullable_to_non_nullable
              as Conversation?,
      conversations: null == conversations
          ? _value._conversations
          : conversations // ignore: cast_nullable_to_non_nullable
              as List<Conversation>,
      newMessage: freezed == newMessage
          ? _value.newMessage
          : newMessage // ignore: cast_nullable_to_non_nullable
              as Message?,
    ));
  }
}

/// @nodoc

class _$MessagesStateImpl implements _MessagesState {
  const _$MessagesStateImpl(
      {required this.timestamp,
      this.device = null,
      this.status = Status.loading,
      this.currentConversation = null,
      final List<Conversation> conversations = const [],
      this.newMessage = null})
      : _conversations = conversations;

  @override
  final int timestamp;
  @override
  @JsonKey()
  final Device? device;
  @override
  @JsonKey()
  final Status status;
  @override
  @JsonKey()
  final Conversation? currentConversation;
  final List<Conversation> _conversations;
  @override
  @JsonKey()
  List<Conversation> get conversations {
    if (_conversations is EqualUnmodifiableListView) return _conversations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conversations);
  }

  @override
  @JsonKey()
  final Message? newMessage;

  @override
  String toString() {
    return 'MessagesState(timestamp: $timestamp, device: $device, status: $status, currentConversation: $currentConversation, conversations: $conversations, newMessage: $newMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessagesStateImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.device, device) || other.device == device) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentConversation, currentConversation) ||
                other.currentConversation == currentConversation) &&
            const DeepCollectionEquality()
                .equals(other._conversations, _conversations) &&
            (identical(other.newMessage, newMessage) ||
                other.newMessage == newMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      timestamp,
      device,
      status,
      currentConversation,
      const DeepCollectionEquality().hash(_conversations),
      newMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessagesStateImplCopyWith<_$MessagesStateImpl> get copyWith =>
      __$$MessagesStateImplCopyWithImpl<_$MessagesStateImpl>(this, _$identity);
}

abstract class _MessagesState implements MessagesState {
  const factory _MessagesState(
      {required final int timestamp,
      final Device? device,
      final Status status,
      final Conversation? currentConversation,
      final List<Conversation> conversations,
      final Message? newMessage}) = _$MessagesStateImpl;

  @override
  int get timestamp;
  @override
  Device? get device;
  @override
  Status get status;
  @override
  Conversation? get currentConversation;
  @override
  List<Conversation> get conversations;
  @override
  Message? get newMessage;
  @override
  @JsonKey(ignore: true)
  _$$MessagesStateImplCopyWith<_$MessagesStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
