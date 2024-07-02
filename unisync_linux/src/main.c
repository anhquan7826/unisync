#include <stdio.h>
#include "device-info.h"
#include "device-message.h"
#include "json-util.h"
#include "mdns.h"

int main(int argc, char **argv)
{
    mdns_registration_new("unisync", "_unisync._tcp", "local", 50810);
    sleep(10);
    mdns_registration_free();
    JsonObject *object;
    object = json_object_new();
    json_object_set_string_member(object, "test", "hello world!");
    UMessage *message = u_message_new_with_values(
        0,
        U_MESSAGE_TYPE_CLIPBOARD,
        object,
        u_message_header_new_with_values(
            U_MESSAGE_HEADER_TYPE_NOTIFICATION,
            "test_method",
            NULL
        ),
        u_message_payload_new_with_values(
            1022,
            1024
        )
    );
    util_json_print(u_message_to_json(message));
    g_object_unref(object);
    g_object_unref(message);
    return 0;
}
