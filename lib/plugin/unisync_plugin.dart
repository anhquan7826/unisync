// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:unisync/plugin/mdns_plugin.dart';
import 'package:unisync/plugin/socket_plugin.dart';
import 'package:unisync/utils/logger.dart';

abstract class UnisyncPlugin {
  late final UnisyncPluginHandler pluginHandler;

  Future<void> start();

  Future<void> stop();

  static const PLUGIN_MDNS = 'mdns';
  static const PLUGIN_SOCKET = 'socket';

  static final Map<String, UnisyncPlugin> _plugins = {};

  static Future<void> startPlugin<T extends UnisyncPlugin>({
    required String type,
    required void Function(UnisyncPluginHandler) onStarted,
    void Function(Exception)? onError,
  }) async {
    try {
      switch (type) {
        case PLUGIN_MDNS:
          if (_plugins.containsKey(PLUGIN_MDNS)) {
            break;
          }
          _plugins[PLUGIN_MDNS] = Platform.isLinux ? AvahiPlugin() : throw Exception('Not implemented!'); // TODO: Implement
          await _plugins[PLUGIN_MDNS]!.start();
          onStarted(MdnsPlugin.getHandler());
          break;
        case PLUGIN_SOCKET:
        if (_plugins.containsKey(PLUGIN_SOCKET)) {
            break;
          }
          _plugins[PLUGIN_SOCKET] = SocketPlugin();
          await _plugins[PLUGIN_SOCKET]!.start();
          onStarted(SocketPlugin.getHandler());
        default:
          throw Exception('Invalid plugin type!');
      }
    } on Exception catch (e) {
      errorLog(e.toString());
      onError?.call(e);
    }
  }
}

abstract class UnisyncPluginHandler {}
