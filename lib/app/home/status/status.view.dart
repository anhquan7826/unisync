import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/status/status.cubit.dart';
import 'package:unisync/resources/resources.dart';
import 'package:unisync/utils/constants/load_state.dart';
import 'package:unisync/utils/extensions/state.ext.dart';
import 'package:unisync/widgets/image.dart';

import '../../../models/device_info/device_info.model.dart';
import 'status.state.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key, required this.deviceInfo});

  final DeviceInfo deviceInfo;

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
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/placeholder_bg.png'),
                    fit: BoxFit.fitWidth,
                    colorFilter: state.loadState == LoadState.loaded
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
              ),
              Padding(
                padding: const EdgeInsets.all(64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.deviceInfo.name,
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    textWithLeading(
                      true ? 'Connected at ${widget.deviceInfo.ip}' : 'Disconnected',
                      leading: const Icon(
                        Icons.circle,
                        size: 12,
                        color: true ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.loadState == LoadState.loaded) ...[
                      Row(
                        children: [
                          textWithLeading(
                            '${state.batteryLevel}%',
                            leading: ColorFiltered(
                              colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                              child: UImage.asset(
                                  imageResource: () {
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
              ),
            ],
          );
        },
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
}
