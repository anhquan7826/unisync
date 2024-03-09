import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/status/status.cubit.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/components/resources/resources.dart';
import 'package:unisync/components/widgets/clickable.dart';
import 'package:unisync/components/widgets/image.dart';
import 'package:unisync/utils/extensions/state.ext.dart';

import '../../../models/device_info/device_info.model.dart';
import 'status.state.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  void initState() {
    super.initState();
    getCubit<StatusCubit>().getStatus();
  }

  @override
  Widget build(BuildContext context) {
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
                    mainAxisSize: MainAxisSize.min,
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
          colorFilter: state.status == Status.loaded
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

  Widget buildStatus(StatusState state) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'widget.deviceInfo.name',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          textWithLeading(
            true ? 'Connected at ${'widget.deviceInfo.ip'}' : 'Disconnected',
            leading: const Icon(
              Icons.circle,
              size: 12,
              color: true ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          if (state.status == Status.loaded) ...[
            Row(
              children: [
                textWithLeading(
                  '${state.batteryLevel}%',
                  leading: ColorFiltered(
                    colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                    child: UImage.asset(() {
                      if (state.isCharging) {
                        return R.icon.battery.charging;
                      } else {
                        if (state.batteryLevel <= 20) {
                          return R.icon.battery.empty;
                        }
                        if (state.batteryLevel <= 40) {
                          return R.icon.battery.quarter;
                        }
                        if (state.batteryLevel <= 60) {
                          return R.icon.battery.half;
                        }
                        if (state.batteryLevel <= 80) {
                          return R.icon.battery.threeQuarter;
                        }
                        return R.icon.battery.full;
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
                R.icon.phoneRing,
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
}
