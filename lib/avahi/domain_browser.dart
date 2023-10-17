// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.Avahi.DomainBrowser.xml

import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.Avahi.DomainBrowser.ItemNew.
class DomainBrowserItemNew extends DBusSignal {
  DomainBrowserItemNew(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  int get interface_ => values[0].asInt32();
  int get protocol => values[1].asInt32();
  String get domain => values[2].asString();
  int get flags => values[3].asUint32();
}

/// Signal data for org.freedesktop.Avahi.DomainBrowser.ItemRemove.
class DomainBrowserItemRemove extends DBusSignal {
  DomainBrowserItemRemove(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  int get interface_ => values[0].asInt32();
  int get protocol => values[1].asInt32();
  String get domain => values[2].asString();
  int get flags => values[3].asUint32();
}

/// Signal data for org.freedesktop.Avahi.DomainBrowser.Failure.
class DomainBrowserFailure extends DBusSignal {
  DomainBrowserFailure(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  String get error => values[0].asString();
}

/// Signal data for org.freedesktop.Avahi.DomainBrowser.AllForNow.
class DomainBrowserAllForNow extends DBusSignal {
  DomainBrowserAllForNow(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.Avahi.DomainBrowser.CacheExhausted.
class DomainBrowserCacheExhausted extends DBusSignal {
  DomainBrowserCacheExhausted(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

class AvahiDomainBrowser extends DBusRemoteObject {
  AvahiDomainBrowser(DBusClient client) : super(client, name: 'org.freedesktop.Avahi', path: DBusObjectPath.root) {
    itemNew = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.DomainBrowser', name: 'ItemNew', signature: DBusSignature('iisu'))
        .asBroadcastStream()
        .map((signal) => DomainBrowserItemNew(signal));

    itemRemove = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.DomainBrowser', name: 'ItemRemove', signature: DBusSignature('iisu'))
        .asBroadcastStream()
        .map((signal) => DomainBrowserItemRemove(signal));

    failure =
        DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.Avahi.DomainBrowser', name: 'Failure', signature: DBusSignature('s'))
            .asBroadcastStream()
            .map((signal) => DomainBrowserFailure(signal));

    allForNow =
        DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.Avahi.DomainBrowser', name: 'AllForNow', signature: DBusSignature(''))
            .asBroadcastStream()
            .map((signal) => DomainBrowserAllForNow(signal));

    cacheExhausted = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.DomainBrowser', name: 'CacheExhausted', signature: DBusSignature(''))
        .asBroadcastStream()
        .map((signal) => DomainBrowserCacheExhausted(signal));
  }

  /// Stream of org.freedesktop.Avahi.DomainBrowser.ItemNew signals.
  late final Stream<DomainBrowserItemNew> itemNew;

  /// Stream of org.freedesktop.Avahi.DomainBrowser.ItemRemove signals.
  late final Stream<DomainBrowserItemRemove> itemRemove;

  /// Stream of org.freedesktop.Avahi.DomainBrowser.Failure signals.
  late final Stream<DomainBrowserFailure> failure;

  /// Stream of org.freedesktop.Avahi.DomainBrowser.AllForNow signals.
  late final Stream<DomainBrowserAllForNow> allForNow;

  /// Stream of org.freedesktop.Avahi.DomainBrowser.CacheExhausted signals.
  late final Stream<DomainBrowserCacheExhausted> cacheExhausted;

  /// Invokes org.freedesktop.Avahi.DomainBrowser.Free()
  Future<void> callFree({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.DomainBrowser', 'Free', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.DomainBrowser.Start()
  Future<void> callStart({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.DomainBrowser', 'Start', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
