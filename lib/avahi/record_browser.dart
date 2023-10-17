// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.Avahi.RecordBrowser.xml

import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.Avahi.RecordBrowser.ItemNew.
class RecordBrowserItemNew extends DBusSignal {
  RecordBrowserItemNew(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  int get interface_ => values[0].asInt32();
  int get protocol => values[1].asInt32();
  String get name_ => values[2].asString();
  int get clazz => values[3].asUint16();
  int get type => values[4].asUint16();
  List<int> get rdata => values[5].asByteArray().toList();
  int get flags => values[6].asUint32();
}

/// Signal data for org.freedesktop.Avahi.RecordBrowser.ItemRemove.
class RecordBrowserItemRemove extends DBusSignal {
  RecordBrowserItemRemove(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  int get interface_ => values[0].asInt32();
  int get protocol => values[1].asInt32();
  String get name_ => values[2].asString();
  int get clazz => values[3].asUint16();
  int get type => values[4].asUint16();
  List<int> get rdata => values[5].asByteArray().toList();
  int get flags => values[6].asUint32();
}

/// Signal data for org.freedesktop.Avahi.RecordBrowser.Failure.
class RecordBrowserFailure extends DBusSignal {
  RecordBrowserFailure(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  String get error => values[0].asString();
}

/// Signal data for org.freedesktop.Avahi.RecordBrowser.AllForNow.
class RecordBrowserAllForNow extends DBusSignal {
  RecordBrowserAllForNow(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.Avahi.RecordBrowser.CacheExhausted.
class RecordBrowserCacheExhausted extends DBusSignal {
  RecordBrowserCacheExhausted(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

class AvahiRecordBrowser extends DBusRemoteObject {
  AvahiRecordBrowser(DBusClient client) : super(client, name: 'org.freedesktop.Avahi', path: DBusObjectPath.root) {
    itemNew = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.RecordBrowser', name: 'ItemNew', signature: DBusSignature('iisqqayu'))
        .asBroadcastStream()
        .map((signal) => RecordBrowserItemNew(signal));

    itemRemove = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.RecordBrowser', name: 'ItemRemove', signature: DBusSignature('iisqqayu'))
        .asBroadcastStream()
        .map((signal) => RecordBrowserItemRemove(signal));

    failure =
        DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.Avahi.RecordBrowser', name: 'Failure', signature: DBusSignature('s'))
            .asBroadcastStream()
            .map((signal) => RecordBrowserFailure(signal));

    allForNow =
        DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.Avahi.RecordBrowser', name: 'AllForNow', signature: DBusSignature(''))
            .asBroadcastStream()
            .map((signal) => RecordBrowserAllForNow(signal));

    cacheExhausted = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.RecordBrowser', name: 'CacheExhausted', signature: DBusSignature(''))
        .asBroadcastStream()
        .map((signal) => RecordBrowserCacheExhausted(signal));
  }

  /// Stream of org.freedesktop.Avahi.RecordBrowser.ItemNew signals.
  late final Stream<RecordBrowserItemNew> itemNew;

  /// Stream of org.freedesktop.Avahi.RecordBrowser.ItemRemove signals.
  late final Stream<RecordBrowserItemRemove> itemRemove;

  /// Stream of org.freedesktop.Avahi.RecordBrowser.Failure signals.
  late final Stream<RecordBrowserFailure> failure;

  /// Stream of org.freedesktop.Avahi.RecordBrowser.AllForNow signals.
  late final Stream<RecordBrowserAllForNow> allForNow;

  /// Stream of org.freedesktop.Avahi.RecordBrowser.CacheExhausted signals.
  late final Stream<RecordBrowserCacheExhausted> cacheExhausted;

  /// Invokes org.freedesktop.Avahi.RecordBrowser.Free()
  Future<void> callFree({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.RecordBrowser', 'Free', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.RecordBrowser.Start()
  Future<void> callStart({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.RecordBrowser', 'Start', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
