import 'package:dbus/dbus.dart';
import 'package:unisync/platform/linux/dbus/avahi_const.dart';
import 'package:unisync/platform/linux/dbus/entry_group.dart';
import 'package:unisync/platform/linux/dbus/server.dart';
import 'package:unisync/plugin/unisync_plugin.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/logger.dart';

abstract class MdnsPlugin extends UnisyncPlugin {
  static MdnsPluginHandler getHandler() {
    return MdnsPluginHandler._();
  }
}

class MdnsPluginHandler extends UnisyncPluginHandler {
  MdnsPluginHandler._();
}

class AvahiPlugin extends MdnsPlugin {
  AvahiPlugin() {
    _server = AvahiServer(_dbus);
  }

  final _dbus = DBusClient.system();
  late final AvahiServer _server;
  late AvahiEntryGroup _entryGroup;

  @override
  Future<void> start() async {
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
      ConfigUtil.serviceType,
      ConfigUtil.serviceDomain,
      '$hostname.$domainName',
      ConfigUtil.discoveryPort,
      [],
    );
    await _entryGroup.callCommit();
    infoLog('Avahi: Service registered.');
  }

  @override
  Future<void> stop() async {}
}
