// ignore_for_file: non_constant_identifier_names, constant_identifier_names
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/device_connection.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/audio_playback/media_metadata.model.dart';
import 'package:unisync/models/audio_playback/media_playback_state.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/utils/payload_handler.dart';

class MediaPluginMethod {
  MediaPluginMethod._();

  static const SESSION_CHANGED = 'session_changed';
  static const SESSION_PROGRESS_CHANGED = 'session_progress_changed';
  static const SESSION_DISPOSED = 'session_disposed';
  static const PLAY_PAUSE = 'play_pause';
  static const SKIP_NEXT = 'skip_next';
  static const SKIP_PREVIOUS = 'skip_previous';
  static const SEEK = 'seek';
}

typedef MediaPlayback = (MediaMetadata, Uint8List?, MediaPlaybackState);

class MediaPlugin extends UnisyncPlugin {
  MediaPlugin(Device device) : super(device, type: DeviceMessage.Type.MEDIA);

  final mediaStream = BehaviorSubject<MediaPlayback?>();

  (MediaMetadata, Uint8List?)? _currentMedia;

  @override
  Future<void> onReceive(
    DeviceMessageHeader header,
    Map<String, dynamic> data,
    Payload? payload,
  ) async {
    super.onReceive(header, data, payload);
    switch (header.method) {
      case MediaPluginMethod.SESSION_CHANGED:
        {
          final coverArt = payload == null
              ? null
              : await getPayloadData(payload.stream, size: payload.size);
          _currentMedia = (
            MediaMetadata.fromJson(data),
            coverArt,
          );
          mediaStream.add((
            _currentMedia!.$1,
            _currentMedia!.$2,
            const MediaPlaybackState(),
          ));
          break;
        }
      case MediaPluginMethod.SESSION_PROGRESS_CHANGED:
        {
          if (_currentMedia != null) {
            mediaStream.add((
              _currentMedia!.$1,
              _currentMedia!.$2,
              MediaPlaybackState.fromJson(data),
            ));
          }
          break;
        }
      case MediaPluginMethod.SESSION_DISPOSED:
        {
          mediaStream.add(null);
          break;
        }
    }
  }

  void toggle() {
    sendRequest(MediaPluginMethod.PLAY_PAUSE);
  }

  void skipNext() {
    sendRequest(MediaPluginMethod.SKIP_NEXT);
  }

  void skipPrevious() {
    sendRequest(MediaPluginMethod.SKIP_PREVIOUS);
  }

  void seek(int position) {
    sendRequest(
      MediaPluginMethod.SEEK,
      data: {
        'position': position,
      },
    );
  }

  @override
  void dispose() {
    mediaStream.close();
    super.dispose();
  }
}
