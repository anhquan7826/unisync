#pragma once

#include <glib-object.h>
#include "device-info.h"

#define U_TYPE_DEVICE u_device_get_type()

G_DECLARE_FINAL_TYPE (UDevice, u_device, U, DEVICE, GObject)

UDevice *u_device_new(UDeviceInfo *info);