import 'dart:io';

import 'package:unisync/backend/mdns.dart';
import 'package:unisync/core/device_entry_point.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/constants/network_ports.dart';
import 'package:unisync/utils/logger.dart';

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
    _serverSockets[address]?.asBroadcastStream().listen(_onNewConnection);
  }

  static Future<void> _onNewConnection(SecureSocket socket) async {
    try {
      infoLog('DeviceDiscovery: Found a service on address ${socket.address.address}.');
      DeviceEntryPoint.create(socket: socket);
    } catch (e) {
      errorLog('DeviceDiscovery: Error connecting to ${socket.address.address}. Exception is:\n$e');
      rethrow;
    }
  }
}
