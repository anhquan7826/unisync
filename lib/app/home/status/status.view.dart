import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/status/status.cubit.dart';
import 'package:unisync/components/resources/resources.dart';
import 'package:unisync/components/widgets/clickable.dart';
import 'package:unisync/components/widgets/image.dart';
import 'package:unisync/models/audio_playback/media_playback_state.dart';
import 'package:unisync/utils/extensions/context.ext.dart';
import 'package:unisync/utils/extensions/list.ext.dart';
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
                      buildMediaControl(),
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
          fit: BoxFit.cover,
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
            device.info.name,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          textWithLeading(
            device.isOnline
                ? R.strings.status.connected_at.tr(args: [
                    getCubit<StatusCubit>().device.ipAddress.toString(),
                  ])
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

  Widget buildMediaControl() {
    return StreamBuilder(
      stream: getCubit<StatusCubit>().getMediaStream(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final textShadow = [
          const Shadow(
            blurRadius: 4,
          ),
        ];
        return AnimatedContainer(
          margin: const EdgeInsets.only(top: 32),
          width: 328,
          decoration: BoxDecoration(
            color: Colors.black,
            image: snapshot.data!.$2 == null
                ? null
                : DecorationImage(
                    image: MemoryImage(snapshot.data!.$2!),
                    fit: BoxFit.cover,
                  ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          duration: const Duration(milliseconds: 250),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!.$1.title ?? 'Unknown title',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.titleM.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: textShadow,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          snapshot.data!.$1.artist ?? 'Unknown artist',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodyM.copyWith(
                            color: Colors.white,
                            shadows: textShadow,
                          ),
                        ),
                        if (snapshot.data!.$1.album != null)
                          Text(
                            snapshot.data!.$1.album!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.labelS.copyWith(
                              color: Colors.white,
                              shadows: textShadow,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton.filled(
                      onPressed: getCubit<StatusCubit>().toggleMedia,
                      icon: Icon(
                        snapshot.data!.$3.state ==
                                MediaPlaybackState.STATE_PAUSED
                            ? Icons.play_arrow_rounded
                            : snapshot.data!.$3.state ==
                                    MediaPlaybackState.STATE_PLAYING
                                ? Icons.pause_rounded
                                : Icons.stop_rounded,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: getCubit<StatusCubit>().skipPrevious,
                    icon: Icon(
                      Icons.skip_previous_rounded,
                      color: context.colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ProgressBar(
                        progress: Duration(
                          milliseconds: snapshot.data!.$3.position ?? 0,
                        ),
                        total: Duration(
                          milliseconds: snapshot.data!.$1.duration ?? 0,
                        ),
                        thumbGlowRadius: 0,
                        thumbRadius: 5,
                        timeLabelTextStyle: context.labelM.copyWith(
                          color: Colors.white,
                          shadows: textShadow,
                        ),
                        onSeek: getCubit<StatusCubit>().seek,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: getCubit<StatusCubit>().skipNext,
                    icon: Icon(
                      Icons.skip_next_rounded,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
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
              icon: const Icon(
                Icons.phonelink_ring_rounded,
                size: 32,
              ),
              onTap: () {
                getCubit<StatusCubit>().ringMyPhone();
              },
            ),
            buildButton(
              label: 'Send clipboard',
              icon: const Icon(
                Icons.content_paste_rounded,
                size: 32,
              ),
              onTap: () {
                getCubit<StatusCubit>().sendClipboard();
              },
            ),
          ].addBetween(const SizedBox(width: 16)),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
