import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/messages/messages.state.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/telephony/telephony.plugin.dart';
import 'package:unisync/models/telephony/telephony.model.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';
import 'package:unisync/utils/extensions/iterable.ext.dart';
import 'package:unisync/utils/extensions/list.ext.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';
import 'package:unisync/utils/logger.dart';

class MessagesCubit extends Cubit<MessagesState> with BaseCubit {
  MessagesCubit(this.device)
      : super(MessagesState(timestamp: DateTime.now().millisecondsSinceEpoch)) {
    load().whenComplete(() => _listen());
  }

  final Device device;

  StreamSubscription? _telephonySubscription;

  Future<void> load() async {
    safeEmit(state.copyWith(
      status: Status.loading,
    ));
    final conversations = (await device
            .getPlugin<TelephonyPlugin>()
            .getAllConversations())
        .map((e) {
      return e.copyWith(
        messages: [...e.messages]..sort((a, b) => a.timestamp - b.timestamp),
      );
    }).toList()
      ..sort((a, b) => a.timestamp - b.timestamp);
    safeEmit(state.copyWith(
      status: Status.loaded,
      conversations: conversations,
    ));
  }

  void _listen() {
    _telephonySubscription =
        device.getPlugin<TelephonyPlugin>().notifier.listen((value) {
      final message = value['new_message'] as Message;
      _onAddMessage(message);
    });
  }

  void setConversation(Conversation conversation) {
    safeEmit(state.copyWith(
      currentConversation: conversation,
    ));
  }

  Future<void> newConversation(String toNumber) async {
    final conversation = state.conversations.firstWhereOrNull((element) {
          return element.number == toNumber;
        }) ??
        Conversation(
          number: toNumber,
          name: await device.getPlugin<TelephonyPlugin>().getContactName(
                toNumber,
              ),
        );
    setConversation(conversation);
  }

  void sendMessage(String message) {
    if (state.currentConversation == null) {
      return;
    }
    final m = Message(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      content: message,
    );
    device.getPlugin<TelephonyPlugin>().sendMessage(
          to: state.currentConversation!.number,
          content: message,
        );
    _onAddMessage(m, state.currentConversation!);
  }

  void _onAddMessage(Message message, [Conversation? ofConversation]) {
    final conversations = [...state.conversations];
    var c = ofConversation ??
        conversations.firstWhereOrNull((p0) => p0.number == message.from);
    if (c == null) {
      c = Conversation(
        number: message.from!,
        name: message.fromName,
        messages: [message],
      );
    } else {
      c = c.copyWith(
        messages: c.messages.plus(message)
          ..sort((a, b) => a.timestamp - b.timestamp),
      );
    }
    conversations
      ..removeWhere((element) => element.number == c!.number)
      ..add(c)
      ..sort((a, b) => a.timestamp - b.timestamp);
    safeEmit(state.copyWith(
      conversations: conversations,
      currentConversation: conversations.firstWhereOrNull(
        (element) => element.number == state.currentConversation?.number,
      ),
    ));
  }

  @override
  Future<void> close() {
    _telephonySubscription?.cancel();
    return super.close();
  }
}
