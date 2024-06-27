#include <stdio.h>
#include "device-info.h"

int main(int argc, char **argv)
{
    UDeviceInfo *device;
    device = u_device_info_new_with_values(
        "Device test",
        DEVICE_TYPE_ANDROID
    );
    g_print("%s", u_device_info_to_string(device));
    return 0;
}
