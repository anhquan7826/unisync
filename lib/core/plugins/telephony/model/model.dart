import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.freezed.dart';
part 'model.g.dart';

@unfreezed
class Conversation with _$Conversation {
  factory Conversation({
    required String personNumber,
    String? personName,
    @Default([]) List<Message> messages,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, Object?> json) => _$ConversationFromJson(json);
}

@freezed
class Message with _$Message {
  const factory Message({
    required int timestamp,
    @Default(null) String? sender,
    required String content,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) => _$MessageFromJson(json);
}
