// ignore_for_file: non_constant_identifier_names
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
  static const _method = (
    GET_GALLERY: 'get_gallery',
    GET_IMAGE: 'get_image',
    GET_THUMBNAIL: 'get_thumbnail',
  );

  Future<List<Media>> getGallery() async {
    final cId = completer<List<Media>>();
    sendRequest(_method.GET_GALLERY);
    messages.listenCancellable((event) {
      if (event.header.type == DeviceMessageHeader.Type.RESPONSE) {
        if (event.header.method == _method.GET_GALLERY) {
          complete(
            cId,
            value: (event.data['gallery'] as List).map((e) {
              return Media.fromJson(e);
            }).toList(),
          );
        } else if (event.header.status == DeviceMessageHeader.Status.ERROR) {
          completeError(cId, error: Exception('No permission'));
        }
        return true;
      } else {
        return false;
      }
    });
    return future(cId);
  }

  Future<Uint8List> getThumbnail(
    int id, [
    int width = 640,
    int height = 640,
  ]) async {
    final cId = completer<Uint8List>();
    sendRequest(
      _method.GET_THUMBNAIL,
      data: {
        'id': id,
        'width': width,
        'height': height,
      },
    );
    messages.listenCancellable((event) {
      if (event.header.type == DeviceMessageHeader.Type.RESPONSE &&
          event.header.method == _method.GET_THUMBNAIL &&
          event.data['image'] == id) {
        getPayloadData(
          event.payload!.stream,
          size: event.payload!.size,
        ).then((value) {
          complete(cId, value: value);
        });
        return true;
      } else {
        return false;
      }
    });
    return future(cId);
  }

  Future<Uint8List> getImage(int id) async {
    final cId = completer<Uint8List>();
    sendRequest(
      _method.GET_IMAGE,
      data: {'id': id},
    );
    messages.listenCancellable((event) {
      if (event.header.type == DeviceMessageHeader.Type.RESPONSE &&
          event.header.method == _method.GET_IMAGE &&
          event.data['image'] == id) {
        getPayloadData(
          event.payload!.stream,
          size: event.payload!.size,
        ).then((value) {
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
