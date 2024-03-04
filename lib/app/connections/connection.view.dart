import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/components/resources/resources.dart';
import 'package:unisync/components/widgets/image.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/extensions/state.ext.dart';

import '../../utils/constants/device_types.dart';
import 'connection.cubit.dart';
import 'connection.state.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: BlocBuilder<ConnectionCubit, DeviceConnectionState>(
        builder: (context, state) {
          if (state.status == Status.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return buildBody(state);
          }
        },
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(R.string.deviceConnection.connectToDevice).tr(),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            // TODO: go to last connected device?
          }
        },
      ),
    );
  }

  Widget buildBody(DeviceConnectionState state) {
    return CustomScrollView(
      slivers: [
        if (state.requestedDevices.isNotEmpty) ...[
          const SliverAppBar(
            title: Text('Requested devices'),
            automaticallyImplyLeading: false,
            primary: false,
            floating: true,
            pinned: true,
          ),
          SliverList.list(
            children: state.requestedDevices.map((e) {
              return buildRequestedDeviceTile(e);
            }).toList(),
          ),
        ],
        if (state.availableDevices.isNotEmpty) ...[
          SliverAppBar(
            title: Text(R.string.deviceConnection.availableDevices).tr(),
            automaticallyImplyLeading: false,
            primary: false,
            floating: true,
            pinned: true,
          ),
          SliverList.list(
            children: state.availableDevices.map((e) {
              return buildDeviceTile(e);
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget buildRequestedDeviceTile(DeviceInfo device) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: UImage.asset(
        device.deviceType == DeviceTypes.android
            ? R.icon.android
            : device.deviceType == DeviceTypes.linux
                ? R.icon.linux
                : R.icon.windows,
        width: 24,
      ),
      title: Text(device.name),
      subtitle: Text(device.ip),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              getCubit<ConnectionCubit>().acceptPair(device);
            },
            icon: const Icon(Icons.close_rounded),
          ),
          IconButton(
            onPressed: () {
              getCubit<ConnectionCubit>().acceptPair(device);
            },
            icon: const Icon(Icons.done_rounded),
          ),
        ],
      ),
    );
  }

  Widget buildDeviceTile(DeviceInfo device) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: UImage.asset(
        device.deviceType == DeviceTypes.android
            ? R.icon.android
            : device.deviceType == DeviceTypes.linux
                ? R.icon.linux
                : R.icon.windows,
        width: 24,
      ),
      title: Text(device.name),
      subtitle: Text(device.ip),
      onTap: () {},
    );
  }

// void showPairDialog(DeviceInfo device) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text(device.name),
//         content: Table(
//           children: [
//             TableRow(
//               children: [
//                 TableCell(
//                   child: Text(R.string.deviceConnection.id).tr(),
//                 ),
//                 TableCell(child: Text(device.id)),
//               ],
//             ),
//             TableRow(
//               children: [
//                 TableCell(
//                   child: Text(R.string.devicePair.ipAddress).tr(),
//                 ),
//                 TableCell(child: Text(device.ip)),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text(
//               R.string.devicePair.cancel,
//             ).tr(),
//           ),
//           TextButton(
//             onPressed: () {
//               // TODO: Send pair request
//               Navigator.of(context).pop();
//             },
//             child: Text(
//               R.string.devicePair.requestPair,
//             ).tr(),
//           ),
//         ],
//       );
//     },
//   );
// }
}

bool validate(String ip) {
  final RegExp ipv4Pattern = RegExp(
    r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$',
    caseSensitive: false,
  );
  return ipv4Pattern.hasMatch(ip);
}
