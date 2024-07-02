#pragma once

#include <glib-object.h>

#define PLUGIN_TYPE_BASE plugin_base_get_type()
G_DECLARE_DERIVABLE_TYPE (PluginBase, plugin_base, PLUGIN, BASE, GObject)

struct _PluginBaseClass {
  GObjectClass parent_class;
};