// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.Avahi.AddressResolver.xml

import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.Avahi.AddressResolver.Found.
class AddressResolverFound extends DBusSignal {
  AddressResolverFound(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  int get interface_ => values[0].asInt32();
  int get protocol => values[1].asInt32();
  int get aprotocol => values[2].asInt32();
  String get address => values[3].asString();
  String get name_ => values[4].asString();
  int get flags => values[5].asUint32();
}

/// Signal data for org.freedesktop.Avahi.AddressResolver.Failure.
class OrgFreedesktopAvahiAddressResolverFailure extends DBusSignal {
  OrgFreedesktopAvahiAddressResolverFailure(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  String get error => values[0].asString();
}

class AvahiAddressResolver extends DBusRemoteObject {
  AvahiAddressResolver(DBusClient client) : super(client, name: 'org.freedesktop.Avahi', path: DBusObjectPath.root) {
    found = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.AddressResolver', name: 'Found', signature: DBusSignature('iiissu'))
        .asBroadcastStream()
        .map((signal) => AddressResolverFound(signal));

    failure =
        DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.Avahi.AddressResolver', name: 'Failure', signature: DBusSignature('s'))
            .asBroadcastStream()
            .map((signal) => OrgFreedesktopAvahiAddressResolverFailure(signal));
  }

  /// Stream of org.freedesktop.Avahi.AddressResolver.Found signals.
  late final Stream<AddressResolverFound> found;

  /// Stream of org.freedesktop.Avahi.AddressResolver.Failure signals.
  late final Stream<OrgFreedesktopAvahiAddressResolverFailure> failure;

  /// Invokes org.freedesktop.Avahi.AddressResolver.Free()
  Future<void> callFree({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.AddressResolver', 'Free', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.AddressResolver.Start()
  Future<void> callStart({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.AddressResolver', 'Start', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
