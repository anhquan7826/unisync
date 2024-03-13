import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/notification/notification.cubit.dart';
import 'package:unisync/app/home/notification/notification.state.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/notification/notification_plugin.dart';
import 'package:unisync/utils/extensions/state.ext.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, required this.device});

  final Device device;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    getCubit<NotificationCubit>().device = widget.device;
  }

  @override
  void didUpdateWidget(covariant NotificationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.device != widget.device) {
      getCubit<NotificationCubit>().device = widget.device;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            actions: [
              IconButton(
                onPressed: () {
                  getCubit<NotificationCubit>().clearAll();
                },
                icon: const Icon(
                  Icons.clear_all,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: state.notifications.length,
            itemBuilder: (context, index) {
              return buildNotification(state.notifications[index]);
            },
          ),
        );
      },
    );
  }

  Widget buildNotification(NotificationData notification) {
    return ListTile(
      key: ValueKey(notification),
      title: Text(notification.title),
      subtitle: Text(notification.text),
      trailing: IconButton(
        onPressed: () {
          getCubit<NotificationCubit>().delete(notification);
        },
        icon: const Icon(
          Icons.delete,
          color: Colors.red,
        ),
      ),
    );
  }
}
