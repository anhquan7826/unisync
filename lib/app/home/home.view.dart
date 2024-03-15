import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (!state.currentDevice.isOnline) {
          currentDest = 0;
          pageController.jumpToPage(currentDest);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: 260,
                child: Column(
                  children: [
                    buildPairedDevices(state),
                    Expanded(
                      child: buildDeviceFeatures(state),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  scrollDirection: Axis.vertical,
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    BlocProvider(
                      create: (context) => StatusCubit(),
                      child: StatusScreen(
                        key: ValueKey(state.currentDevice.info.hashCode),
                        device: state.currentDevice,
                      ),
                    ),
                    const FileTransferScreen(),
                    const GalleryScreen(),
                    BlocProvider(
                      create: (context) => MessagesCubit(),
                      child: MessagesScreen(
                        key: ValueKey(state.currentDevice.info.hashCode + 3),
                        device: state.currentDevice,
                      ),
                    ),
                    BlocProvider(
                      create: (context) => NotificationCubit(),
                      child: NotificationScreen(
                        key: ValueKey(state.currentDevice.info.hashCode + 4),
                        device: state.currentDevice,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int currentDest = 0;

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
          borderRadius: BorderRadius.circular(24),
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
                color: index == currentDest ? R.color.mainColor.withOpacity(0.2) : null,
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

    return ListView(
      children: [
        buildDestination(
          0,
          icon: UImage.asset(R.icon.info),
          label: R.string.home.information.tr(),
        ),
        buildDestination(
          1,
          enabled: state.currentDevice.isOnline,
          icon: UImage.asset(R.icon.exchange),
          label: R.string.home.fileExplorer.tr(),
        ),
        buildDestination(
          2,
          enabled: state.currentDevice.isOnline,
          icon: UImage.asset(R.icon.gallery),
          label: R.string.home.gallery.tr(),
        ),
        buildDestination(
          3,
          enabled: state.currentDevice.isOnline,
          icon: UImage.asset(R.icon.messages),
          label: R.string.home.messages.tr(),
        ),
        buildDestination(
          4,
          enabled: state.currentDevice.isOnline,
          icon: UImage.asset(R.icon.notification),
          label: R.string.home.notifications.tr(),
        ),
      ],
    );
  }

  Widget buildPairedDevices(HomeState state) {
    Widget buildDevice(Device device, {bool isSelected = false, void Function()? onTap}) {
      return Clickable(
        key: GlobalKey(),
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isSelected ? R.color.mainColor.withOpacity(0.2) : null,
          ),
          child: Row(
            children: [
              UImage.asset(
                R.icon.smartPhone,
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
                    device.isOnline ? R.string.status.connected.tr() : R.string.status.disconnected.tr(),
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
              R.icon.computer,
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
                    R.string.appName,
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
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // TODO: edit name
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: UImage.asset(
                              R.icon.edit,
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
                R.string.deviceConnection.pairedDevices,
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
              child: Text(R.string.home.manageDevices).tr(),
            ),
          ],
        ),
      ],
    );
  }
}
