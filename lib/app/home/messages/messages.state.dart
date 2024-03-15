import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/telephony/model/model.dart';

part 'messages.state.freezed.dart';

@freezed
class MessagesState with _$MessagesState {
  const factory MessagesState({
    required int timestamp,
    @Default(null) Device? device,
    @Default(Status.loading) Status status,
    @Default(null) Conversation? currentConversation,
    @Default([]) List<Conversation> conversations,
    @Default(null) Message? newMessage,
  }) = _MessagesState;
}
