//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <clipboard_watcher/clipboard_watcher_plugin.h>
#include <flutter_volume_controller/flutter_volume_controller_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  ClipboardWatcherPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ClipboardWatcherPlugin"));
  FlutterVolumeControllerPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterVolumeControllerPluginCApi"));
}
