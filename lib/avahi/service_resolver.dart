// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.Avahi.ServiceResolver.xml

import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.Avahi.ServiceResolver.Found.
class ServiceResolverFound extends DBusSignal {
  ServiceResolverFound(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  int get interface_ => values[0].asInt32();
  int get protocol => values[1].asInt32();
  String get name_ => values[2].asString();
  String get type => values[3].asString();
  String get domain => values[4].asString();
  String get host => values[5].asString();
  int get aprotocol => values[6].asInt32();
  String get address => values[7].asString();
  int get port => values[8].asUint16();
  List<List<int>> get txt => values[9].asArray().map((child) => child.asByteArray().toList()).toList();
  int get flags => values[10].asUint32();
}

/// Signal data for org.freedesktop.Avahi.ServiceResolver.Failure.
class ServiceResolverFailure extends DBusSignal {
  ServiceResolverFailure(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  String get error => values[0].asString();
}

class AvahiServiceResolver extends DBusRemoteObject {
  AvahiServiceResolver(DBusClient client) : super(client, name: 'org.freedesktop.Avahi', path: DBusObjectPath.root) {
    found = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.ServiceResolver', name: 'Found', signature: DBusSignature('iissssisqaayu'))
        .asBroadcastStream()
        .map((signal) => ServiceResolverFound(signal));

    failure =
        DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.Avahi.ServiceResolver', name: 'Failure', signature: DBusSignature('s'))
            .asBroadcastStream()
            .map((signal) => ServiceResolverFailure(signal));
  }

  /// Stream of org.freedesktop.Avahi.ServiceResolver.Found signals.
  late final Stream<ServiceResolverFound> found;

  /// Stream of org.freedesktop.Avahi.ServiceResolver.Failure signals.
  late final Stream<ServiceResolverFailure> failure;

  /// Invokes org.freedesktop.Avahi.ServiceResolver.Free()
  Future<void> callFree({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.ServiceResolver', 'Free', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.ServiceResolver.Start()
  Future<void> callStart({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.ServiceResolver', 'Start', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
