#pragma once
#include <glib-object.h>

#define DEVICE_TYPE_ANDROID "android"
#define DEVICE_TYPE_LINUX "linux"
#define DEVICE_TYPE_WINDOWS "windows"

#define U_TYPE_DEVICE_INFO u_device_info_get_type()
G_DECLARE_FINAL_TYPE (UDeviceInfo, u_device_info, U, DEVICE_INFO, GObject)

UDeviceInfo* u_device_info_new_with_values (const gchar* name, const gchar* type);

gchar* u_device_info_to_string(UDeviceInfo *self);