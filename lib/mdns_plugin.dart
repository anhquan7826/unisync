import 'dart:convert';
import 'dart:typed_data';

import 'package:dbus/dbus.dart';
import 'package:unisync/avahi/entry_group.dart';
import 'package:unisync/avahi/server2.dart';
import 'package:unisync/constants/device_types.dart';
import 'package:unisync/extensions/map.ext.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/converters.dart';

Future<void> testDBus() async {
  final client = DBusClient.system();
  final server2 = AvahiServer2(client);
  final entryGroup = AvahiEntryGroup(client, await server2.callEntryGroupNew());
  final hostname = await server2.callGetHostName();
  final domainName = await server2.callGetDomainName();
  final info = DeviceInfo(id: 'sadfsd123dsf3fe324', name: 'AnhQuan-Linux', deviceType: DeviceTypes.linux).toJson();
  await entryGroup.callAddService(-1, 0, 0, 'unisync@linux', '_unisync._tcp.', 'local', '$hostname.$domainName', 50810, [
    Uint8List.fromList(info.toJsonString().codeUnits)
  ]);
  await entryGroup.callCommit();
}
