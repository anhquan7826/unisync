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
import 'package:unisync/utils/logger.dart';

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
    final images = <Uint8List>[];
    for (final g in gallery) {
      images.add(await device.getPlugin<GalleryPlugin>().getImage(g.id));
    }
    safeEmit(state.copyWith(
      media: List.generate(gallery.length, (index) {
        return (gallery[index], images[index]);
      }),
    ));
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
    await file.writeAsBytes(
      state.media.firstWhere((element) => element.$1 == media).$2!,
    );
  }
}
