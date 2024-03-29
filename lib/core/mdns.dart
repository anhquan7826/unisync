import 'package:flutter/services.dart';

abstract class MDNS {
  Future<void> registerService({
    required String name,
    required String type,
    required String domain,
    required int port,
  });
}

class LinuxMDNS extends MDNS {
  // final avahi = Avahi();

  @override
  Future<void> registerService({required String name, required String type, required String domain, required int port}) async {
    // await avahi.register(
    //   name: name,
    //   type: type,
    //   domain: domain,
    //   port: port,
    // );
    const MethodChannel('com.anhquan.unisync/mdns').invokeMethod('register');
  }
}

class WindowsMDNS extends MDNS {
  @override
  Future<void> registerService({required String name, required String type, required String domain, required int port}) {
    throw UnimplementedError();
  }
}
