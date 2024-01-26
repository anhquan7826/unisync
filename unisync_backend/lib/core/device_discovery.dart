import 'dart:io';

import 'package:unisync_backend/core/device_provider.dart';
import 'package:unisync_backend/utils/configs.dart';
import 'package:unisync_backend/utils/constants/network_ports.dart';
import 'package:unisync_backend/utils/extensions/map.ext.dart';
import 'package:unisync_backend/utils/extensions/string.ext.dart';
import 'package:unisync_backend/utils/extensions/uint8list.ext.dart';
import 'package:unisync_backend/utils/logger.dart';

import '../models/device_info/device_info.model.dart';
import 'mdns.dart';

class DeviceDiscovery {
  DeviceDiscovery._();

  static final Map<String, SecureServerSocket> _serverSockets = {};
  static final MDNS _mdns = Platform.isLinux ? LinuxMDNS() : WindowsMDNS();

  static Future<void> start() async {
    await _mdns.registerService(
      name: Platform.isLinux ? 'unisync@linux' : 'unisync@windows',
      type: ConfigUtil.serviceType,
      domain: ConfigUtil.serviceDomain,
      port: ConfigUtil.discoveryPort,
    );
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        await _createServerSocket(address.address);
      }
    }
    _createServerSocket('127.0.0.1');
  }

  static Future<void> _createServerSocket(String address) async {
    final context = SecurityContext.defaultContext
      ..useCertificateChainBytes(ConfigUtil.authentication.getCertificate().codeUnits)
      ..usePrivateKeyBytes(ConfigUtil.authentication.getPrivateKeyString().codeUnits);
    _serverSockets[address] = await SecureServerSocket.bind(address, NetworkPorts.socketPort, context);
    infoLog('AppSocket: Created server socket on $address.');
    _serverSockets[address]?.listen((socket) {
      _onNewConnection(socket);
    });
  }

  static Future<void> _onNewConnection(SecureSocket socket) async {
    try {
      infoLog('DeviceDiscovery: Found a service on address ${socket.address.address}.');
      socket.writeln((await ConfigUtil.device.getDeviceInfo()).toJson().toJsonString());
      final inputStream = socket.asBroadcastStream();
      final info = DeviceInfo.fromJson((await inputStream.first).string.toMap()).copy(ip: socket.address.address);
      DeviceProvider.create(info: info, socket: socket, inputStream: inputStream);
    } catch (e) {
      errorLog('DeviceDiscovery: Error connecting to ${socket.address.address}. Exception is:\n$e');
      rethrow;
    }
  }
}
