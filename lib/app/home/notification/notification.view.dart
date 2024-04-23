import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/notification/notification.cubit.dart';
import 'package:unisync/app/home/notification/notification.state.dart';
import 'package:unisync/components/resources/resources.dart';
import 'package:unisync/components/widgets/image.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/models/notification_data/notification_data.model.dart';
import 'package:unisync/utils/extensions/context.ext.dart';
import 'package:unisync/utils/extensions/state.ext.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, required this.device});

  final Device device;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with AutomaticKeepAliveClientMixin<NotificationScreen> {
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
    super.build(context);
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
    return Container(
      key: ValueKey(notification),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 100),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     blurRadius: 16,
        //     spreadRadius: 4,
        //   ),
        // ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (notification.icon != null)
            UImage.bytes(
              notification.icon!,
              width: 42,
              height: 42,
            )
          else
            UImage.asset(
              R.vectors.app_icon,
              width: 42,
              height: 42,
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.appName,
                  style: context.labelM.copyWith(
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 4,
                  ),
                  child: Text(
                    notification.title,
                    style: context.bodyM.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  notification.text,
                  style: context.bodyS,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              getCubit<NotificationCubit>().delete(notification);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
