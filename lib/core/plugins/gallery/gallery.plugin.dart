import 'dart:async';
import 'dart:typed_data';

import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';
import 'package:unisync/models/media/media.model.dart';
import 'package:unisync/utils/extensions/stream.ext.dart';
import 'package:unisync/utils/payload_handler.dart';

class GalleryPlugin extends UnisyncPlugin {
  GalleryPlugin(Device device)
      : super(
          device,
          type: DeviceMessage.Type.GALLERY,
        );

  Future<List<Media>> getGallery() async {
    final cId = completer<List<Media>>();
    send({
      'func': 'get_gallery',
    });
    messages.listenCancellable((event) {
      if (event.data.containsKey('gallery')) {
        complete(cId,
            value: (event.data['gallery'] as List).map((e) {
              return Media.fromJson(e);
            }).toList());
        return true;
      } else {
        return false;
      }
    });
    return future(cId);
  }

  Future<Uint8List> getImage(int id) async {
    final cId = completer<Uint8List>();
    send({
      'func': 'get_image',
      'id': id,
    });
    messages.listenCancellable((event) {
      if (event.data['image'] == id) {
        getPayloadData(event.payload!.stream, size: event.payload!.size).then((value) {
          complete(cId, value: value);
        });
        return true;
      } else {
        return false;
      }
    });
    return future(cId);
  }
}
