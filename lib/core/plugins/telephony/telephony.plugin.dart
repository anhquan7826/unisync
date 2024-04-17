import 'package:unisync/core/device_connection.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/models/telephony/telephony.model.dart';
import 'package:unisync/utils/extensions/stream.ext.dart';

class TelephonyPlugin extends UnisyncPlugin {
  TelephonyPlugin(super.device) : super(type: DeviceMessage.Type.TELEPHONY);

  @override
  void onReceive(Map<String, dynamic> data, Payload? payload) {
    super.onReceive(data, payload);
    switch (data['func']) {
      case 'on_new_message':
        final message = Message.fromJson(data['message']);
        _onNewMessage(message);
        break;
    }
  }

  Future<List<Conversation>> getAllConversations() async {
    final c = completer<List<Conversation>>();
    send({'func': 'get_messages'});
    messages.listenCancellable((event) {
      if (event.data['func_response'] == 'get_messages') {
        final conversations = (event.data['conversations'] as List)
            .map(
              (e) => Conversation.fromJson(e),
            )
            .toList();
        complete(c, value: conversations);
        return true;
      }
      return false;
    });
    return future(c);
  }

  Future<String?> getContactName(String number) {
    final c = completer<String?>();
    send({
      'func': 'get_contact',
      'number': number,
    });
    messages.listenCancellable((value) {
      if (value.data['func_response'] == 'get_contact') {
        complete(c, value: value.data['name']);
        return true;
      }
      return false;
    });
    return future(c);
  }

  void _onNewMessage(Message message) {
    notifier.add({
      'new_message': message,
    });
  }

  void sendMessage({required String to, required String content}) {
    send({
      'func': 'send_message',
      'to': to,
      'content': content,
    });
  }
}
