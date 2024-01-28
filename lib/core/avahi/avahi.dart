// import 'package:dbus/dbus.dart';
//
// import '../../utils/logger.dart';
// import 'avahi_const.dart';
// import 'entry_group.dart';
// import 'server.dart';
//
// class Avahi {
//   Avahi() {
//     _server = AvahiServer(_dbus);
//   }
//
//   final _dbus = DBusClient.system();
//   late final AvahiServer _server;
//   late AvahiEntryGroup _entryGroup;
//
//   Future<void> register({required String name, required String type, required String domain, required int port}) async {
//     while (await _server.callGetState() != AvahiServerState.AVAHI_SERVER_RUNNING) {}
//     final hostname = await _server.callGetHostName();
//     final domainName = await _server.callGetDomainName();
//     _entryGroup = AvahiEntryGroup(_dbus, await _server.callEntryGroupNew());
//     await _entryGroup.callAddService(
//       -1,
//       0,
//       0,
//       name,
//       type,
//       domain,
//       '$hostname.$domainName',
//       port,
//       [],
//     );
//     await _entryGroup.callCommit();
//     infoLog('Avahi: Service registered.');
//   }
// }
