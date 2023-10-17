// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.Avahi.ServiceBrowser.xml

import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.Avahi.ServiceBrowser.ItemNew.
class ServiceBrowserItemNew extends DBusSignal {
  ServiceBrowserItemNew(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  int get interface_ => values[0].asInt32();
  int get protocol => values[1].asInt32();
  String get name_ => values[2].asString();
  String get type => values[3].asString();
  String get domain => values[4].asString();
  int get flags => values[5].asUint32();
}

/// Signal data for org.freedesktop.Avahi.ServiceBrowser.ItemRemove.
class ServiceBrowserItemRemove extends DBusSignal {
  ServiceBrowserItemRemove(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  int get interface_ => values[0].asInt32();
  int get protocol => values[1].asInt32();
  String get name_ => values[2].asString();
  String get type => values[3].asString();
  String get domain => values[4].asString();
  int get flags => values[5].asUint32();
}

/// Signal data for org.freedesktop.Avahi.ServiceBrowser.Failure.
class ServiceBrowserFailure extends DBusSignal {
  ServiceBrowserFailure(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  String get error => values[0].asString();
}

/// Signal data for org.freedesktop.Avahi.ServiceBrowser.AllForNow.
class ServiceBrowserAllForNow extends DBusSignal {
  ServiceBrowserAllForNow(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.Avahi.ServiceBrowser.CacheExhausted.
class ServiceBrowserCacheExhausted extends DBusSignal {
  ServiceBrowserCacheExhausted(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

class AvahiServiceBrowser extends DBusRemoteObject {
  AvahiServiceBrowser(DBusClient client) : super(client, name: 'org.freedesktop.Avahi', path: DBusObjectPath.root) {
    itemNew = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.ServiceBrowser', name: 'ItemNew', signature: DBusSignature('iisssu'))
        .asBroadcastStream()
        .map((signal) => ServiceBrowserItemNew(signal));

    itemRemove = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.ServiceBrowser', name: 'ItemRemove', signature: DBusSignature('iisssu'))
        .asBroadcastStream()
        .map((signal) => ServiceBrowserItemRemove(signal));

    failure =
        DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.Avahi.ServiceBrowser', name: 'Failure', signature: DBusSignature('s'))
            .asBroadcastStream()
            .map((signal) => ServiceBrowserFailure(signal));

    allForNow =
        DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.Avahi.ServiceBrowser', name: 'AllForNow', signature: DBusSignature(''))
            .asBroadcastStream()
            .map((signal) => ServiceBrowserAllForNow(signal));

    cacheExhausted = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.ServiceBrowser', name: 'CacheExhausted', signature: DBusSignature(''))
        .asBroadcastStream()
        .map((signal) => ServiceBrowserCacheExhausted(signal));
  }

  /// Stream of org.freedesktop.Avahi.ServiceBrowser.ItemNew signals.
  late final Stream<ServiceBrowserItemNew> itemNew;

  /// Stream of org.freedesktop.Avahi.ServiceBrowser.ItemRemove signals.
  late final Stream<ServiceBrowserItemRemove> itemRemove;

  /// Stream of org.freedesktop.Avahi.ServiceBrowser.Failure signals.
  late final Stream<ServiceBrowserFailure> failure;

  /// Stream of org.freedesktop.Avahi.ServiceBrowser.AllForNow signals.
  late final Stream<ServiceBrowserAllForNow> allForNow;

  /// Stream of org.freedesktop.Avahi.ServiceBrowser.CacheExhausted signals.
  late final Stream<ServiceBrowserCacheExhausted> cacheExhausted;

  /// Invokes org.freedesktop.Avahi.ServiceBrowser.Free()
  Future<void> callFree({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.ServiceBrowser', 'Free', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.ServiceBrowser.Start()
  Future<void> callStart({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.ServiceBrowser', 'Start', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
