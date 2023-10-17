// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.Avahi.ServiceTypeBrowser.xml

import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.Avahi.ServiceTypeBrowser.ItemNew.
class ServiceTypeBrowserItemNew extends DBusSignal {
  ServiceTypeBrowserItemNew(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  int get interface_ => values[0].asInt32();
  int get protocol => values[1].asInt32();
  String get type => values[2].asString();
  String get domain => values[3].asString();
  int get flags => values[4].asUint32();
}

/// Signal data for org.freedesktop.Avahi.ServiceTypeBrowser.ItemRemove.
class ServiceTypeBrowserItemRemove extends DBusSignal {
  ServiceTypeBrowserItemRemove(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  int get interface_ => values[0].asInt32();
  int get protocol => values[1].asInt32();
  String get type => values[2].asString();
  String get domain => values[3].asString();
  int get flags => values[4].asUint32();
}

/// Signal data for org.freedesktop.Avahi.ServiceTypeBrowser.Failure.
class ServiceTypeBrowserFailure extends DBusSignal {
  ServiceTypeBrowserFailure(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  String get error => values[0].asString();
}

/// Signal data for org.freedesktop.Avahi.ServiceTypeBrowser.AllForNow.
class ServiceTypeBrowserAllForNow extends DBusSignal {
  ServiceTypeBrowserAllForNow(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.Avahi.ServiceTypeBrowser.CacheExhausted.
class ServiceTypeBrowserCacheExhausted extends DBusSignal {
  ServiceTypeBrowserCacheExhausted(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

class AvahiServiceTypeBrowser extends DBusRemoteObject {
  AvahiServiceTypeBrowser(DBusClient client) : super(client, name: 'org.freedesktop.Avahi', path: DBusObjectPath.root) {
    itemNew = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.ServiceTypeBrowser', name: 'ItemNew', signature: DBusSignature('iissu'))
        .asBroadcastStream()
        .map((signal) => ServiceTypeBrowserItemNew(signal));

    itemRemove = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.ServiceTypeBrowser', name: 'ItemRemove', signature: DBusSignature('iissu'))
        .asBroadcastStream()
        .map((signal) => ServiceTypeBrowserItemRemove(signal));

    failure = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.ServiceTypeBrowser', name: 'Failure', signature: DBusSignature('s'))
        .asBroadcastStream()
        .map((signal) => ServiceTypeBrowserFailure(signal));

    allForNow = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.ServiceTypeBrowser', name: 'AllForNow', signature: DBusSignature(''))
        .asBroadcastStream()
        .map((signal) => ServiceTypeBrowserAllForNow(signal));

    cacheExhausted = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.ServiceTypeBrowser', name: 'CacheExhausted', signature: DBusSignature(''))
        .asBroadcastStream()
        .map((signal) => ServiceTypeBrowserCacheExhausted(signal));
  }

  /// Stream of org.freedesktop.Avahi.ServiceTypeBrowser.ItemNew signals.
  late final Stream<ServiceTypeBrowserItemNew> itemNew;

  /// Stream of org.freedesktop.Avahi.ServiceTypeBrowser.ItemRemove signals.
  late final Stream<ServiceTypeBrowserItemRemove> itemRemove;

  /// Stream of org.freedesktop.Avahi.ServiceTypeBrowser.Failure signals.
  late final Stream<ServiceTypeBrowserFailure> failure;

  /// Stream of org.freedesktop.Avahi.ServiceTypeBrowser.AllForNow signals.
  late final Stream<ServiceTypeBrowserAllForNow> allForNow;

  /// Stream of org.freedesktop.Avahi.ServiceTypeBrowser.CacheExhausted signals.
  late final Stream<ServiceTypeBrowserCacheExhausted> cacheExhausted;

  /// Invokes org.freedesktop.Avahi.ServiceTypeBrowser.Free()
  Future<void> callFree({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.ServiceTypeBrowser', 'Free', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.ServiceTypeBrowser.Start()
  Future<void> callStart({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.ServiceTypeBrowser', 'Start', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
