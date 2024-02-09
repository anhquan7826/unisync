//
// Created by anhquan7826 on 1/28/24.
//
#include "mdns.h"

static void server_state_callback(AvahiClient *s, AvahiClientState state, void *userdata) {
    if (state == AVAHI_CLIENT_S_RUNNING) {
        g_print("Avahi server is running. Registering entry group...\n");
        group = avahi_entry_group_new(s, nullptr, nullptr);
        avahi_entry_group_add_service(
                group,
                AVAHI_IF_UNSPEC,
                AVAHI_PROTO_UNSPEC,
                AVAHI_PUBLISH_USE_MULTICAST,
                name,
                type,
                domain,
                nullptr,
                port,
                nullptr);
        avahi_entry_group_commit(group);
        g_print("mdns.cc: Service registered!\n");
    }
}

void service_registration_new(const char *_name, const char *_type, const char *_domain, int _port) {
    name = _name;
    type = _type;
    domain = _domain;
    port = _port;
    g_print("mdns.cc: Registering service...\n");
    simple_poll = avahi_simple_poll_new();
    client = avahi_client_new(
            avahi_simple_poll_get(simple_poll),
            AVAHI_CLIENT_NO_FAIL,
            server_state_callback,
            nullptr,
            nullptr
    );
}

void service_registration_free() {
    avahi_entry_group_free(group);
    avahi_client_free(client);
    avahi_simple_poll_free(simple_poll);
}
