import 'dart:convert';

import 'package:unisync/core/device_connection.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/models/telephony/telephony.model.dart';
import 'package:unisync/utils/extensions/stream.ext.dart';
import 'package:unisync/utils/payload_handler.dart';

class TelephonyPlugin extends UnisyncPlugin {
  TelephonyPlugin(super.device) : super(type: DeviceMessage.Type.TELEPHONY);
  static const _Method = (
    GET_MESSAGES: 'get_messages',
    SEND_MESSAGE: 'send_message',
    GET_CONTACT: 'get_contact',
    NEW_MESSAGE: 'new_message',
  );

  @override
  void onReceive(
    DeviceMessageHeader header,
    Map<String, dynamic> data,
    Payload? payload,
  ) {
    super.onReceive(header, data, payload);
    if (header.method == _Method.NEW_MESSAGE) {
      final message = Message.fromJson(data['message']);
      _onNewMessage(message);
    }
  }

  Future<List<Conversation>> getAllConversations() async {
    final c = completer<List<Conversation>>();
    sendRequest(_Method.GET_MESSAGES);
    messages.listenCancellable((event) async {
      if (event.header.type == DeviceMessageHeader.Type.RESPONSE) {
        if (event.header.method == _Method.GET_MESSAGES) {
          if (event.payload != null) {
            final jsonString = await getPayloadData(
              event.payload!.stream,
              size: event.payload!.size,
            ).then((it) => utf8.decode(it));
            final json = jsonDecode(jsonString);
            final conversations = (json['conversations'] as List)
                .map((e) => Conversation.fromJson(e))
                .toList();
            complete(c, value: conversations);
          } else {
            complete(c, value: []);
          }
        } else if (event.header.status == DeviceMessageHeader.Status.ERROR) {
          completeError(c, error: Exception('No Permission'));
        }
        return true;
      }
      return false;
    });
    return future(c);
  }

  Future<String?> getContactName(String number) {
    final c = completer<String?>();
    sendRequest(
      _Method.GET_CONTACT,
      data: {'number': number},
    );
    messages.listenCancellable((value) {
      if (value.header.type == DeviceMessageHeader.Type.RESPONSE &&
          value.header.method == _Method.GET_CONTACT) {
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
    sendRequest(
      _Method.SEND_MESSAGE,
      data: {
        'to': to,
        'content': content,
      },
    );
  }
}
