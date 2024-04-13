import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/status/status.cubit.dart';
import 'package:unisync/components/resources/resources.dart';
import 'package:unisync/components/widgets/clickable.dart';
import 'package:unisync/components/widgets/image.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/utils/extensions/state.ext.dart';

import 'status.state.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen>
    with AutomaticKeepAliveClientMixin<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: BlocBuilder<StatusCubit, StatusState>(
        builder: (context, state) {
          return Stack(
            fit: StackFit.passthrough,
            children: [
              if (state.wallpaper != null) buildBackground(state),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 64,
                    left: 64,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildStatus(state),
                      buildButtons(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildBackground(StatusState state) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.memory(state.wallpaper!).image,
          fit: BoxFit.fitWidth,
          colorFilter: true
              ? null
              : const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.saturation,
                ),
        ),
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.8),
              Colors.transparent,
            ],
            stops: const [0.3, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget textWithLeading(String text, {required Widget leading}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        const SizedBox(width: 8),
        Text(
          text,
        ),
      ],
    );
  }

  Widget buildDisconnected() {
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

  Widget buildStatus(StatusState state) {
    final device = getCubit<StatusCubit>().device;
    return Padding(
      padding: const EdgeInsets.only(
        right: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            device.info.name ?? 'null',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          textWithLeading(
            device.isOnline
                ? R.strings.status.connected_at
                    .tr(args: [state.ipAddress.toString()])
                : R.strings.status.disconnected.tr(),
            leading: Icon(
              Icons.circle,
              size: 12,
              color: device.isOnline ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          if (device.isOnline) ...[
            Row(
              children: [
                textWithLeading(
                  '${state.batteryLevel}%',
                  leading: ColorFiltered(
                    colorFilter:
                        const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                    child: UImage.asset(() {
                      if (state.isCharging) {
                        return R.vectors.battery_bolt;
                      } else {
                        if (state.batteryLevel <= 20) {
                          return R.vectors.battery_empty;
                        }
                        if (state.batteryLevel <= 40) {
                          return R.vectors.battery_quarter;
                        }
                        if (state.batteryLevel <= 60) {
                          return R.vectors.battery_half;
                        }
                        if (state.batteryLevel <= 80) {
                          return R.vectors.battery_three_quarters;
                        }
                        return R.vectors.battery_full;
                      }
                    }.call()),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget buildButtons() {
    Widget buildButton({
      required String label,
      required Widget icon,
      required void Function() onTap,
    }) {
      return Clickable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 256,
          height: 128,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                spreadRadius: 4,
              )
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              const SizedBox(
                height: 8,
              ),
              Text(label),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildButton(
              label: 'Find my phone',
              icon: UImage.asset(
                R.vectors.phone_ring,
                width: 32,
                height: 32,
              ),
              onTap: () {
                getCubit<StatusCubit>().ringMyPhone();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
