import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/gallery/gallery.state.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/gallery/gallery.plugin.dart';
import 'package:unisync/models/media/media.model.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';
import 'package:unisync/utils/extensions/list.ext.dart';
import 'package:unisync/utils/logger.dart';
import 'package:unisync/utils/push_notification.dart';

class GalleryCubit extends Cubit<GalleryState> with BaseCubit {
  GalleryCubit(this.device) : super(const GalleryState()) {
    getGallery().then((value) => debugLog);
  }

  final Device device;

  Future<void> getGallery() async {
    final gallery = await device.getPlugin<GalleryPlugin>().getGallery();
    safeEmit(state.copyWith(
      media: gallery.map((e) => (e, null)).toList(),
    ));
    _loadThumbnails();
  }

  Future<void> _loadThumbnails() async {
    for (int i = 0; i < state.media.length; i++) {
      final medium = state.media[i].$1;
      device.getPlugin<GalleryPlugin>().getThumbnail(medium.id).then((value) {
        safeEmit(state.copyWith(
          media: state.media.copyReplacedIndex(
              (index) => index == i ? (medium, value) : null),
        ));
      });
    }
  }

  Future<void> saveImage(Media media) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Choose saving location...',
      fileName: media.name,
    );
    if (path == null) {
      return;
    }
    final file = File(path);
    final image = await device.getPlugin<GalleryPlugin>().getImage(media.id);
    await file.writeAsBytes(image);
    PushNotification.showNotification(
      title: 'Image received!',
      text: path,
    );
  }
}
