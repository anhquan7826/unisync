// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.Avahi.HostNameResolver.xml

import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.Avahi.HostNameResolver.Found.
class HostNameResolverFound extends DBusSignal {
  HostNameResolverFound(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  int get interface_ => values[0].asInt32();
  int get protocol => values[1].asInt32();
  String get name_ => values[2].asString();
  int get aprotocol => values[3].asInt32();
  String get address => values[4].asString();
  int get flags => values[5].asUint32();
}

/// Signal data for org.freedesktop.Avahi.HostNameResolver.Failure.
class HostNameResolverFailure extends DBusSignal {
  HostNameResolverFailure(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  String get error => values[0].asString();
}

class AvahiHostNameResolver extends DBusRemoteObject {
  AvahiHostNameResolver(DBusClient client) : super(client, name: 'org.freedesktop.Avahi', path: DBusObjectPath.root) {
    found = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.HostNameResolver', name: 'Found', signature: DBusSignature('iisisu'))
        .asBroadcastStream()
        .map((signal) => HostNameResolverFound(signal));

    failure = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.HostNameResolver', name: 'Failure', signature: DBusSignature('s'))
        .asBroadcastStream()
        .map((signal) => HostNameResolverFailure(signal));
  }

  /// Stream of org.freedesktop.Avahi.HostNameResolver.Found signals.
  late final Stream<HostNameResolverFound> found;

  /// Stream of org.freedesktop.Avahi.HostNameResolver.Failure signals.
  late final Stream<HostNameResolverFailure> failure;

  /// Invokes org.freedesktop.Avahi.HostNameResolver.Free()
  Future<void> callFree({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.HostNameResolver', 'Free', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.HostNameResolver.Start()
  Future<void> callStart({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.HostNameResolver', 'Start', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
