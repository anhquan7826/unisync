import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/app/home/messages/messages.cubit.dart';
import 'package:unisync/app/home/messages/messages.state.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/components/resources/resources.dart';
import 'package:unisync/components/widgets/clickable.dart';
import 'package:unisync/models/telephony/telephony.model.dart';
import 'package:unisync/utils/extensions/context.ext.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';
import 'package:unisync/utils/extensions/state.ext.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<MessagesCubit, MessagesState>(
      builder: (context, state) {
        if (state.status == Status.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Row(
          children: [
            Expanded(
              child: buildConversationPanel(state),
            ),
            const VerticalDivider(
              width: 1,
            ),
            Expanded(
              flex: 2,
              child: buildMessagePanel(state),
            ),
          ],
        );
      },
    );
  }

  Widget buildConversationPanel(MessagesState state) {
    return Scaffold(
      appBar: AppBar(
        title: Text(R.strings.messages.conversations).tr(),
        actions: [
          IconButton(
            onPressed: getCubit<MessagesCubit>().load,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: state.conversations.reversed.map((c) {
          return buildConversation(
            c,
            isSelected: c == state.currentConversation,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showNewConversationDialog().then((value) {
            if (value != null) {
              getCubit<MessagesCubit>().newConversation(value);
            }
          });
        },
        label: const Text('New conversation'),
        icon: const Icon(Icons.message_rounded),
      ),
    );
  }

  final controller = TextEditingController();

  Widget buildMessagePanel(MessagesState state) {
    if (state.currentConversation == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            R.strings.messages.conversation_not_chosen,
            textAlign: TextAlign.center,
          ).tr(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.currentConversation!.name != null)
                Text(
                  state.currentConversation!.name!,
                  style: context.bodyM.copyWith(fontWeight: FontWeight.w600),
                ),
              Text(
                state.currentConversation!.number,
                style: (state.currentConversation!.name != null)
                    ? context.bodyS.copyWith(
                        color: Colors.grey,
                      )
                    : context.bodyM.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
              )
            ],
          ),
          centerTitle: true,
        ),
        body: ListView(
          reverse: true,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: state.currentConversation!.messages.reversed.map((e) {
            return buildMessage(e);
          }).toList(),
        ),
        bottomNavigationBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  hintText: R.strings.messages.hint.tr(),
                ),
                textInputAction: TextInputAction.send,
                keyboardType: TextInputType.text,
                onSubmitted: (value) {
                  getCubit<MessagesCubit>().sendMessage(value.trim());
                  controller.clear();
                },
              ),
            ),
            IconButton.filled(
              onPressed: () {
                getCubit<MessagesCubit>().sendMessage(controller.text.trim());
                controller.clear();
              },
              icon: const Icon(Icons.send_rounded),
            ),
            const SizedBox(width: 16)
          ],
        ),
      );
    }
  }

  Widget buildConversation(Conversation c, {bool isSelected = false}) {
    return Clickable(
      onTap: () {
        getCubit<MessagesCubit>().setConversation(c);
      },
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? Color(R.colors.main_color).withOpacity(0.2) : null,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c.name ?? c.number,
              style: context.bodyM.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (c.messages.isNotEmpty)
              c.messages.last.let((it) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    (it.from == null)
                        ? R.strings.messages.me.tr(args: [it.content])
                        : it.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyS.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                );
              })
          ],
        ),
      ),
    );
  }

  Widget buildMessage(Message m) {
    Widget buildTimestamp(int epoch) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          formatTimestamp(epoch),
          style: context.labelM.copyWith(
            color: Colors.grey,
          ),
        ),
      );
    }

    return Align(
      alignment: m.from == null ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (m.from == null) buildTimestamp(m.timestamp),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: m.from == null
                  ? Colors.grey.withOpacity(0.5)
                  : Color(R.colors.main_color).withOpacity(0.25),
            ),
            child: Text(m.content),
          ),
          if (m.from != null) buildTimestamp(m.timestamp),
        ],
      ),
    );
  }

  Future<String?> showNewConversationDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return const _NewConversationDialog();
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  String formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final isSameDate = dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
    final formattedTime =
        DateFormat(isSameDate ? 'HH:mm' : 'dd/MM/yyyy HH:mm').format(dateTime);
    return formattedTime;
  }
}

class _NewConversationDialog extends StatefulWidget {
  const _NewConversationDialog({super.key});

  @override
  State<_NewConversationDialog> createState() => _NewConversationDialogState();
}

class _NewConversationDialogState extends State<_NewConversationDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New conversation'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 200,
        ),
        child: TextField(
          controller: controller,
          inputFormatters: [
            FilteringTextInputFormatter(RegExp(r'\d'), allow: true),
          ],
          decoration: const InputDecoration(
            prefixText: 'To: ',
            labelText: 'Phone number',
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            context.pop(value.isEmpty ? null : value);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop(controller.text.isEmpty ? null : controller.text);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
