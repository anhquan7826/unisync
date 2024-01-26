// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.Avahi.Server.xml

import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.Avahi.Server.StateChanged.
class ServerStateChanged extends DBusSignal {
  ServerStateChanged(DBusSignal signal)
      : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
  int get state => values[0].asInt32();
  String get error => values[1].asString();
}

class AvahiServer extends DBusRemoteObject {
  AvahiServer(DBusClient client) : super(client, name: 'org.freedesktop.Avahi', path: DBusObjectPath.root) {
    stateChanged = DBusRemoteObjectSignalStream(
      object: this,
      interface: 'org.freedesktop.Avahi.Server',
      name: 'StateChanged',
      signature: DBusSignature('is'),
    ).asBroadcastStream().map((signal) => ServerStateChanged(signal));
  }

  /// Stream of org.freedesktop.Avahi.Server.StateChanged signals.
  late final Stream<ServerStateChanged> stateChanged;

  /// Invokes org.freedesktop.Avahi.Server.GetVersionString()
  Future<String> callGetVersionString({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'GetVersionString', [],
        replySignature: DBusSignature('s'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.Avahi.Server.GetAPIVersion()
  Future<int> callGetAPIVersion({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'GetAPIVersion', [],
        replySignature: DBusSignature('u'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asUint32();
  }

  /// Invokes org.freedesktop.Avahi.Server.GetHostName()
  Future<String> callGetHostName({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'GetHostName', [],
        replySignature: DBusSignature('s'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.Avahi.Server.SetHostName()
  Future<void> callSetHostName(String name, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.Server', 'SetHostName', [DBusString(name)],
        replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.Server.GetHostNameFqdn()
  Future<String> callGetHostNameFqdn({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'GetHostNameFqdn', [],
        replySignature: DBusSignature('s'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.Avahi.Server.GetDomainName()
  Future<String> callGetDomainName({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'GetDomainName', [],
        replySignature: DBusSignature('s'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.Avahi.Server.IsNSSSupportAvailable()
  Future<bool> callIsNSSSupportAvailable({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'IsNSSSupportAvailable', [],
        replySignature: DBusSignature('b'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asBoolean();
  }

  /// Invokes org.freedesktop.Avahi.Server.GetState()
  Future<int> callGetState({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'GetState', [],
        replySignature: DBusSignature('i'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asInt32();
  }

  /// Invokes org.freedesktop.Avahi.Server.GetLocalServiceCookie()
  Future<int> callGetLocalServiceCookie({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'GetLocalServiceCookie', [],
        replySignature: DBusSignature('u'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asUint32();
  }

  /// Invokes org.freedesktop.Avahi.Server.GetAlternativeHostName()
  Future<String> callGetAlternativeHostName(String name, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'GetAlternativeHostName', [DBusString(name)],
        replySignature: DBusSignature('s'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.Avahi.Server.GetAlternativeServiceName()
  Future<String> callGetAlternativeServiceName(String name, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'GetAlternativeServiceName', [DBusString(name)],
        replySignature: DBusSignature('s'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.Avahi.Server.GetNetworkInterfaceNameByIndex()
  Future<String> callGetNetworkInterfaceNameByIndex(int index, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'GetNetworkInterfaceNameByIndex', [DBusInt32(index)],
        replySignature: DBusSignature('s'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.Avahi.Server.GetNetworkInterfaceIndexByName()
  Future<int> callGetNetworkInterfaceIndexByName(String name, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'GetNetworkInterfaceIndexByName', [DBusString(name)],
        replySignature: DBusSignature('i'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asInt32();
  }

  /// Invokes org.freedesktop.Avahi.Server.ResolveHostName()
  Future<List<DBusValue>> callResolveHostName(int interface, int protocol, String name, int aprotocol, int flags,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'ResolveHostName',
        [DBusInt32(interface), DBusInt32(protocol), DBusString(name), DBusInt32(aprotocol), DBusUint32(flags)],
        replySignature: DBusSignature('iisisu'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues;
  }

  /// Invokes org.freedesktop.Avahi.Server.ResolveAddress()
  Future<List<DBusValue>> callResolveAddress(int interface, int protocol, String address, int flags,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server', 'ResolveAddress', [DBusInt32(interface), DBusInt32(protocol), DBusString(address), DBusUint32(flags)],
        replySignature: DBusSignature('iiissu'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues;
  }

  /// Invokes org.freedesktop.Avahi.Server.ResolveService()
  Future<List<DBusValue>> callResolveService(int interface, int protocol, String name, String type, String domain, int aprotocol, int flags,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'ResolveService',
        [DBusInt32(interface), DBusInt32(protocol), DBusString(name), DBusString(type), DBusString(domain), DBusInt32(aprotocol), DBusUint32(flags)],
        replySignature: DBusSignature('iissssisqaayu'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues;
  }

  /// Invokes org.freedesktop.Avahi.Server.EntryGroupNew()
  Future<DBusObjectPath> callEntryGroupNew({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'EntryGroupNew', [],
        replySignature: DBusSignature('o'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.Avahi.Server.DomainBrowserNew()
  Future<DBusObjectPath> callDomainBrowserNew(int interface, int protocol, String domain, int btype, int flags,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'DomainBrowserNew',
        [DBusInt32(interface), DBusInt32(protocol), DBusString(domain), DBusInt32(btype), DBusUint32(flags)],
        replySignature: DBusSignature('o'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.Avahi.Server.ServiceTypeBrowserNew()
  Future<DBusObjectPath> callServiceTypeBrowserNew(int interface, int protocol, String domain, int flags,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server', 'ServiceTypeBrowserNew', [DBusInt32(interface), DBusInt32(protocol), DBusString(domain), DBusUint32(flags)],
        replySignature: DBusSignature('o'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.Avahi.Server.ServiceBrowserNew()
  Future<DBusObjectPath> callServiceBrowserNew(int interface, int protocol, String type, String domain, int flags,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'ServiceBrowserNew',
        [DBusInt32(interface), DBusInt32(protocol), DBusString(type), DBusString(domain), DBusUint32(flags)],
        replySignature: DBusSignature('o'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.Avahi.Server.ServiceResolverNew()
  Future<DBusObjectPath> callServiceResolverNew(int interface, int protocol, String name, String type, String domain, int aprotocol, int flags,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'ServiceResolverNew',
        [DBusInt32(interface), DBusInt32(protocol), DBusString(name), DBusString(type), DBusString(domain), DBusInt32(aprotocol), DBusUint32(flags)],
        replySignature: DBusSignature('o'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.Avahi.Server.HostNameResolverNew()
  Future<DBusObjectPath> callHostNameResolverNew(int interface, int protocol, String name, int aprotocol, int flags,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'HostNameResolverNew',
        [DBusInt32(interface), DBusInt32(protocol), DBusString(name), DBusInt32(aprotocol), DBusUint32(flags)],
        replySignature: DBusSignature('o'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.Avahi.Server.AddressResolverNew()
  Future<DBusObjectPath> callAddressResolverNew(int interface, int protocol, String address, int flags,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server', 'AddressResolverNew', [DBusInt32(interface), DBusInt32(protocol), DBusString(address), DBusUint32(flags)],
        replySignature: DBusSignature('o'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.Avahi.Server.RecordBrowserNew()
  Future<DBusObjectPath> callRecordBrowserNew(int interface, int protocol, String name, int clazz, int type, int flags,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server', 'RecordBrowserNew',
        [DBusInt32(interface), DBusInt32(protocol), DBusString(name), DBusUint16(clazz), DBusUint16(type), DBusUint32(flags)],
        replySignature: DBusSignature('o'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }
}
