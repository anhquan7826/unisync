import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/app/desktop/home/file_transfer/file_transfer.view.dart';
import 'package:unisync/app/desktop/home/gallery/gallery.view.dart';
import 'package:unisync/app/desktop/home/messages/messages.view.dart';
import 'package:unisync/app/desktop/home/notification/notification.view.dart';
import 'package:unisync/resources/resources.dart';
import 'package:unisync/routes/routes.dart';
import 'package:unisync/widgets/image.dart';
import 'package:unisync_backend/models/device_info/device_info.model.dart';

import 'status/status.view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.device});

  final DeviceInfo device;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentDest = 0;

  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 120,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: PopupMenuButton(
                    tooltip: '',
                    icon: Column(
                      children: [
                        const Icon(
                          Icons.phone_android_outlined,
                          weight: 200,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.device.name,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    position: PopupMenuPosition.under,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            UImage.asset(
                              imageResource: R.icon.android,
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(widget.device.name),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        height: 1,
                        enabled: false,
                        child: Divider(),
                      ),
                      PopupMenuItem(
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              weight: 100,
                            ),
                            SizedBox(width: 8),
                            Text('Add new device'),
                          ],
                        ),
                        onTap: () {
                          context.pushNamed(DesktopRouter.routes.pair);
                        },
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    color: Colors.black,
                    height: 1,
                  ),
                ),
                Expanded(
                  child: NavigationRail(
                    selectedIndex: currentDest,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      NavigationRailDestination(
                        icon: UImage.asset(imageResource: R.icon.info),
                        label: const Text('Information'),
                      ),
                      NavigationRailDestination(
                        icon: UImage.asset(imageResource: R.icon.exchange),
                        label: const Text('File Explorer'),
                      ),
                      NavigationRailDestination(
                        icon: UImage.asset(imageResource: R.icon.gallery),
                        label: const Text('Gallery'),
                      ),
                      NavigationRailDestination(
                        icon: UImage.asset(imageResource: R.icon.messages),
                        label: const Text('Messages'),
                      ),
                      NavigationRailDestination(
                        icon: UImage.asset(imageResource: R.icon.notification),
                        label: const Text('Notifications'),
                      ),
                    ],
                    onDestinationSelected: (index) {
                      setState(() {
                        currentDest = index;
                        pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: UImage.asset(
                    imageResource: R.icon.settings,
                    width: 32,
                    height: 32,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const VerticalDivider(
            width: 1,
          ),
          Expanded(
            child: PageView(
              scrollDirection: Axis.vertical,
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatusScreen(deviceInfo: widget.device),
                const FileTransferScreen(),
                const GalleryScreen(),
                const MessagesScreen(),
                const NotificationScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
