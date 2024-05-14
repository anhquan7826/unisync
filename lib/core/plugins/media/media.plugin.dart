import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

class MediaPlugin extends UnisyncPlugin {
  MediaPlugin(Device device) : super(device, type: DeviceMessage.Type.MEDIA);


}