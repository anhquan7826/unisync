// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.Avahi.EntryGroup.xml

import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.Avahi.EntryGroup.StateChanged.
class EntryGroupStateChanged extends DBusSignal {
  EntryGroupStateChanged(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  int get state => values[0].asInt32();
  String get error => values[1].asString();
}

class AvahiEntryGroup extends DBusRemoteObject {
  AvahiEntryGroup(DBusClient client, DBusObjectPath path) : super(client, name: 'org.freedesktop.Avahi', path: path) {
    stateChanged = DBusRemoteObjectSignalStream(
            object: this, interface: 'org.freedesktop.Avahi.EntryGroup', name: 'StateChanged', signature: DBusSignature('is'))
        .asBroadcastStream()
        .map((signal) => EntryGroupStateChanged(signal));
  }

  /// Stream of org.freedesktop.Avahi.EntryGroup.StateChanged signals.
  late final Stream<EntryGroupStateChanged> stateChanged;

  /// Invokes org.freedesktop.Avahi.EntryGroup.Free()
  Future<void> callFree({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.EntryGroup', 'Free', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.EntryGroup.Commit()
  Future<void> callCommit({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.EntryGroup', 'Commit', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.EntryGroup.Reset()
  Future<void> callReset({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.EntryGroup', 'Reset', [],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.EntryGroup.GetState()
  Future<int> callGetState({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.EntryGroup', 'GetState', [],
        replySignature: DBusSignature('i'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asInt32();
  }

  /// Invokes org.freedesktop.Avahi.EntryGroup.IsEmpty()
  Future<bool> callIsEmpty({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.EntryGroup', 'IsEmpty', [],
        replySignature: DBusSignature('b'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asBoolean();
  }

  /// Invokes org.freedesktop.Avahi.EntryGroup.AddService()
  Future<void> callAddService(
      int interface, int protocol, int flags, String name, String type, String domain, String host, int port, List<List<int>> txt,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod(
        'org.freedesktop.Avahi.EntryGroup',
        'AddService',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusUint32(flags),
          DBusString(name),
          DBusString(type),
          DBusString(domain),
          DBusString(host),
          DBusUint16(port),
          DBusArray(DBusSignature('ay'), txt.map((child) => DBusArray.byte(child)))
        ],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.EntryGroup.AddServiceSubtype()
  Future<void> callAddServiceSubtype(int interface, int protocol, int flags, String name, String type, String domain, String subtype,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.EntryGroup', 'AddServiceSubtype',
        [DBusInt32(interface), DBusInt32(protocol), DBusUint32(flags), DBusString(name), DBusString(type), DBusString(domain), DBusString(subtype)],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.EntryGroup.UpdateServiceTxt()
  Future<void> callUpdateServiceTxt(int interface, int protocol, int flags, String name, String type, String domain, List<List<int>> txt,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod(
        'org.freedesktop.Avahi.EntryGroup',
        'UpdateServiceTxt',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusUint32(flags),
          DBusString(name),
          DBusString(type),
          DBusString(domain),
          DBusArray(DBusSignature('ay'), txt.map((child) => DBusArray.byte(child)))
        ],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.EntryGroup.AddAddress()
  Future<void> callAddAddress(int interface, int protocol, int flags, String name, String address,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.EntryGroup', 'AddAddress',
        [DBusInt32(interface), DBusInt32(protocol), DBusUint32(flags), DBusString(name), DBusString(address)],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.EntryGroup.AddRecord()
  Future<void> callAddRecord(int interface, int protocol, int flags, String name, int clazz, int type, int ttl, List<int> rdata,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod(
        'org.freedesktop.Avahi.EntryGroup',
        'AddRecord',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusUint32(flags),
          DBusString(name),
          DBusUint16(clazz),
          DBusUint16(type),
          DBusUint32(ttl),
          DBusArray.byte(rdata)
        ],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
