import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/desktop/home/home.cubit.dart';
import 'package:unisync/app/desktop/home/home.state.dart';
import 'package:unisync/app/desktop/home/status/status.state.dart';
import 'package:unisync/resources/resources.dart';
import 'package:unisync/widgets/image.dart';
import 'package:unisync_backend/models/device_info/device_info.model.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key, required this.deviceInfo});

  final DeviceInfo deviceInfo;

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (_, state) => state is StatusState,
        builder: (context, state) {
          if (state is LoadingStatusState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final isConnected = (state as StatusLoadedState).isConnected;
          final battery = state.battery;
          final connectivity = state.connectivity;
          return Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/placeholder_bg.png'),
                    fit: BoxFit.fitWidth,
                    colorFilter: isConnected
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
                      isConnected ? 'Connected at ${widget.deviceInfo.ip}' : 'Disconnected',
                      leading: Icon(
                        Icons.circle,
                        size: 12,
                        color: isConnected ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isConnected) ...[
                      Row(
                        children: [
                          textWithLeading(
                            '${state.battery}%',
                            leading: ColorFiltered(
                              colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                              child: UImage.asset(imageResource: R.icon.battery.full),
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
