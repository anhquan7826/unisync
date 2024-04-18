import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/app/home/file_transfer/file_transfer.cubit.dart';
import 'package:unisync/app/home/gallery/gallery.cubit.dart';
import 'package:unisync/app/home/home.cubit.dart';
import 'package:unisync/app/home/home.state.dart';
import 'package:unisync/app/home/messages/messages.cubit.dart';
import 'package:unisync/app/home/notification/notification.cubit.dart';
import 'package:unisync/app/home/status/status.cubit.dart';
import 'package:unisync/components/resources/resources.dart';
import 'package:unisync/components/widgets/clickable.dart';
import 'package:unisync/components/widgets/expandable_list.dart';
import 'package:unisync/components/widgets/image.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/pairing_handler.dart';
import 'package:unisync/routes/routes.dart';
import 'package:unisync/utils/extensions/context.ext.dart';
import 'package:unisync/utils/extensions/state.ext.dart';

import 'file_transfer/file_transfer.view.dart';
import 'gallery/gallery.view.dart';
import 'messages/messages.view.dart';
import 'notification/notification.view.dart';
import 'status/status.view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final pageController = PageController();
  int currentDest = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: 260,
                child: ListView(
                  children: [
                    buildPairedDevices(state),
                    buildDeviceFeatures(state),
                  ],
                ),
              ),
              Expanded(
                child: buildBody(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildBody(HomeState state) {
    if (!state.currentDevice.isOnline) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UImage.asset(
            R.vectors.warning,
            width: 64,
            height: 64,
          ),
          const SizedBox(height: 16),
          Text(
            R.strings.status.device_offline,
            textAlign: TextAlign.center,
          ).tr(),
        ],
      );
    }
    if (state.currentDevice.pairState != PairState.paired) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UImage.asset(
            R.vectors.warning,
            width: 64,
            height: 64,
          ),
          const SizedBox(height: 16),
          Text(
            R.strings.status.device_offline,
            textAlign: TextAlign.center,
          ).tr(),
        ],
      );
    }
    return PageView(
      scrollDirection: Axis.vertical,
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        BlocProvider(
          create: (context) => StatusCubit(state.currentDevice),
          child: StatusScreen(
            key: ValueKey(state.currentDevice.info.hashCode),
          ),
        ),
        BlocProvider(
          create: (context) => FileTransferCubit(state.currentDevice),
          child: const FileTransferScreen(),
        ),
        BlocProvider(
          key: ValueKey(state.currentDevice.info.hashCode + 2),
          create: (context) => GalleryCubit(state.currentDevice),
          child: const GalleryScreen(),
        ),
        BlocProvider(
          key: ValueKey(state.currentDevice.info.hashCode + 3),
          create: (context) => MessagesCubit(state.currentDevice),
          child: const MessagesScreen(),
        ),
        BlocProvider(
          key: ValueKey(state.currentDevice.info.hashCode + 4),
          create: (context) => NotificationCubit(),
          child: NotificationScreen(
            device: state.currentDevice,
          ),
        ),
      ],
    );
  }

  Widget buildDeviceFeatures(HomeState state) {
    Widget buildDestination(
      int index, {
      bool enabled = true,
      required String label,
      required Widget icon,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Clickable(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          onTap: !enabled
              ? null
              : () {
                  setState(() {
                    currentDest = index;
                    pageController.jumpToPage(index);
                  });
                },
          child: Opacity(
            opacity: enabled ? 1 : 0.25,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: index == currentDest
                    ? Color(R.colors.main_color).withOpacity(0.2)
                    : null,
              ),
              child: Row(
                children: [
                  icon,
                  const SizedBox(
                    width: 16,
                  ),
                  Text(label),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildDestination(
          0,
          icon: UImage.asset(R.vectors.info),
          label: R.strings.home.information.tr(),
        ),
        buildDestination(
          1,
          enabled: state.currentDevice.isOnline,
          icon: UImage.asset(R.vectors.exchange),
          label: R.strings.home.file_explorer.tr(),
        ),
        buildDestination(
          2,
          enabled: state.currentDevice.isOnline,
          icon: UImage.asset(R.vectors.gallery),
          label: R.strings.home.gallery.tr(),
        ),
        buildDestination(
          3,
          enabled: state.currentDevice.isOnline,
          icon: UImage.asset(R.vectors.messages),
          label: R.strings.home.messages.tr(),
        ),
        buildDestination(
          4,
          enabled: state.currentDevice.isOnline,
          icon: UImage.asset(R.vectors.notification),
          label: R.strings.home.notifications.tr(),
        ),
      ],
    );
  }

  Widget buildPairedDevices(HomeState state) {
    Widget buildDevice(Device device,
        {bool isSelected = false, void Function()? onTap}) {
      return Clickable(
        key: GlobalKey(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color:
                isSelected ? Color(R.colors.main_color).withOpacity(0.2) : null,
          ),
          child: Row(
            children: [
              UImage.asset(
                R.vectors.smartphone,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.info.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    device.isOnline
                        ? R.strings.status.connected.tr()
                        : R.strings.status.disconnected.tr(),
                    style: context.labelM.copyWith(
                      color: device.isOnline ? Colors.green : Colors.grey,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            UImage.asset(
              R.vectors.computer,
              width: 42,
              height: 42,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    R.strings.app_name,
                    style: context.displayS.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ).tr(),
                  if (state.myDevice != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            state.myDevice!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Clickable(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onTap: () {
                            showDialog<String?>(
                              context: context,
                              builder: (context) {
                                return _EditNameDialog(
                                  previousName: state.myDevice?.name,
                                );
                              },
                            ).then((value) {
                              if (value != null) {
                                getCubit<HomeCubit>().renameMyDevice(value);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: UImage.asset(
                              R.vectors.edit,
                              width: 14,
                              height: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: buildDevice(state.currentDevice),
        ),
        ExpandableList(
          children: [
            Padding(
              key: GlobalKey(),
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                R.strings.device_connection.paired_devices,
              ).tr(),
            ),
            ...state.pairedDevices.map((e) => buildDevice(
                  e,
                  isSelected: e == state.currentDevice,
                  onTap: () {
                    getCubit<HomeCubit>().setDevice(e);
                  },
                )),
            TextButton(
              key: GlobalKey(),
              onPressed: () {
                context.pushNamed(routes.pair);
              },
              child: Text(R.strings.home.manage_devices).tr(),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({this.previousName});

  final String? previousName;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.previousName ?? '';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(R.strings.home.rename_this_device.tr()),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 150,
        ),
        child: TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(R.strings.home.cancel.tr()),
        ),
        TextButton(
          onPressed: controller.text.isEmpty ||
                  controller.text.trim() == widget.previousName
              ? null
              : () => context.pop(controller.text.trim()),
          child: Text(R.strings.home.save.tr()),
        ),
      ],
    );
  }
}
