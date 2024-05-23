import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

part 'telephony.model.freezed.dart';

part 'telephony.model.g.dart';

@freezed
class Conversation with _$Conversation {
  factory Conversation({
    required String number,
    String? name,
    @Default([]) List<Message> messages,
  }) = _Conversation;

  const Conversation._();

  factory Conversation.fromJson(Map<String, Object?> json) =>
      _$ConversationFromJson(json);

  int get timestamp => messages.last.timestamp;

  Message get latestMessage => messages.last;
}

@freezed
class Message with _$Message {
  const factory Message({
    required int timestamp,
    String? from,
    String? fromName,
    required String content,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) =>
      _$MessageFromJson(json);
}
