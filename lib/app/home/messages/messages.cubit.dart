import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/messages/messages.state.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/telephony/model/model.dart';
import 'package:unisync/core/plugins/telephony/telephony.plugin.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';

class MessagesCubit extends Cubit<MessagesState> with BaseCubit {
  MessagesCubit() : super(MessagesState(timestamp: DateTime.now().millisecondsSinceEpoch));

  Device? _device;

  Device? get device => _device;

  set device(Device? value) {
    if (_device != value) {
      _deviceSubscription?.cancel();
      _telephonySubscription?.cancel();
    }
    _device = value;
    if (_device != null) {
      safeEmit(state.copyWith(device: _device));
      _listen();
      _device!.getPlugin<TelephonyPlugin>().getAllMessages();
    }
  }

  StreamSubscription? _deviceSubscription;
  StreamSubscription? _telephonySubscription;

  void _listen() {
    _deviceSubscription = device!.notifier.listen((value) {
      if (value.connected) {
        _telephonySubscription = device!.getPlugin<TelephonyPlugin>().notifier.listen((value) {
          safeEmit(state.copyWith(
            timestamp: DateTime.now().millisecondsSinceEpoch,
            status: Status.loaded,
            conversations: value['conversations'] as List<Conversation>,
            newMessage: value['new_message'] as Message?,
          ));
        });
        device!.getPlugin<TelephonyPlugin>().getAllMessages();
      } else {
        _telephonySubscription?.cancel();
      }
    });
  }

  void setConversation(Conversation conversation) {
    safeEmit(state.copyWith(
      currentConversation: conversation,
    ));
  }

  void sendMessage(String message) {
    if (state.currentConversation == null) {
      return;
    }
    device!.getPlugin<TelephonyPlugin>().sendMessage(
          personNumber: state.currentConversation!.personNumber,
          content: message,
        );
  }

  @override
  Future<void> close() {
    _telephonySubscription?.cancel();
    _deviceSubscription?.cancel();
    return super.close();
  }
}
