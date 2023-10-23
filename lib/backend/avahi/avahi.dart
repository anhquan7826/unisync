import 'package:dbus/dbus.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/logger.dart';

import 'dbus/avahi_const.dart';
import 'dbus/entry_group.dart';
import 'dbus/server.dart';

class Avahi {
  Avahi() {
    _server = AvahiServer(_dbus);
  }

  final _dbus = DBusClient.system();
  late final AvahiServer _server;
  late AvahiEntryGroup _entryGroup;

  Future<void> register() async {
    if (await _server.callGetState() == AvahiServerState.AVAHI_SERVER_RUNNING) {
      infoLog('AvahiServer: AVAHI_SERVER_RUNNING');
      await _registerService();
    }
    _server.stateChanged.listen(_avahiServerListener);
  }

  Future<void> _avahiServerListener(ServerStateChanged event) async {
    switch (event.state) {
      case AvahiServerState.AVAHI_SERVER_RUNNING:
        infoLog('AvahiServer: AVAHI_SERVER_RUNNING');
        await _entryGroup.callFree();
        _registerService();
        break;

      case AvahiServerState.AVAHI_SERVER_REGISTERING:
        infoLog('AvahiServer: AVAHI_SERVER_REGISTERING');
        break;

      case AvahiServerState.AVAHI_SERVER_COLLISION:
        infoLog('AvahiServer: AVAHI_SERVER_COLLISION');
      case AvahiServerState.AVAHI_SERVER_FAILURE:
        infoLog('AvahiServer: AVAHI_SERVER_FAILURE');
      case AvahiServerState.AVAHI_SERVER_INVALID:
        infoLog('AvahiServer: AVAHI_SERVER_INVALID');
        errorLog('AvahiServer: error: ${event.error}');
        break;
    }
  }

  Future<void> _registerService() async {
    final hostname = await _server.callGetHostName();
    final domainName = await _server.callGetDomainName();
    _entryGroup = AvahiEntryGroup(_dbus, await _server.callEntryGroupNew());
    await _entryGroup.callAddService(
      -1,
      0,
      0,
      'unisync@linux',
      AppConfig.serviceType,
      AppConfig.serviceDomain,
      '$hostname.$domainName',
      AppConfig.discoveryPort,
      [],
    );
    await _entryGroup.callCommit();
    infoLog('Avahi: Service registered.');
  }
}
