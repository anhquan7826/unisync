import 'package:unisync/core/device_connection.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/core/plugins/telephony/model/model.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

class TelephonyPlugin extends UnisyncPlugin {
  TelephonyPlugin(super.device) : super(type: DeviceMessage.Type.TELEPHONY);

  List<Conversation> conversations = [];

  @override
  void onReceive(Map<String, dynamic> data, Payload? payload) {
    super.onReceive(data, payload);
    if (data.containsKey('messages')) {
      conversations = (data['messages'] as List).map((e) => Conversation.fromJson(e)).toList();
      notifier.add({
        'conversations': conversations,
      });
    } else if (data.containsKey('new_message')) {
      final message = Message.fromJson(data['new_message']);
      if (!conversations.any((element) => element.personNumber == message.sender)) {
        conversations.insert(
          0,
          Conversation(
            personNumber: message.sender!,
            messages: [message],
          ),
        );
      } else {
        conversations
            .firstWhere((element) {
              return element.personNumber == message.sender;
            })
            .messages
            .add(message);
      }
      notifier.add({
        'conversations': conversations,
        'new_message': message,
      });
    }
  }

  void getAllMessages() {
    send({'get_messages': ''});
  }

  void sendMessage({required String personNumber, required String content}) {
    send({
      'send_message': '',
      'person': personNumber,
      'content': content,
    });
    final message = Message(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      content: content,
    );
    conversations
        .firstWhere((element) {
          return element.personNumber == personNumber;
        })
        .messages
        .add(message);
    notifier.add({
      'conversations': conversations,
      'new_message': message,
    });
  }
}
