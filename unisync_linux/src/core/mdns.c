#include "mdns.h"

static const char* name;
static const char* type;
static const char* domain;
static int port;

static AvahiSimplePoll *simple_poll;
static AvahiClient* client;
static AvahiEntryGroup *group;

static void server_state_callback(AvahiClient *s, AvahiClientState state, void *userdata) 
{
    if (state == AVAHI_CLIENT_S_RUNNING) {
        g_print("Avahi server is running. Registering mDNS...\n");
        group = avahi_entry_group_new(s, NULL, NULL);
        avahi_entry_group_add_service(
            group,
            AVAHI_IF_UNSPEC,
            AVAHI_PROTO_UNSPEC,
            AVAHI_PUBLISH_USE_MULTICAST,
            name,
            type,
            domain,
            NULL,
            port,
            NULL
        );
        avahi_entry_group_commit(group);
        g_print("mDNS registered!\n");
    }
}

void mdns_registration_new(const char *_name, const char *_type, const char *_domain, int _port) 
{
    name = _name;
    type = _type;
    domain = _domain;
    port = _port;
    g_print("Registering service...\n");
    simple_poll = avahi_simple_poll_new();
    client = avahi_client_new(
            avahi_simple_poll_get(simple_poll),
            AVAHI_CLIENT_NO_FAIL,
            server_state_callback,
            NULL,
            NULL
    );
}

void mdns_registration_free() 
{
    avahi_entry_group_free(group);
    avahi_client_free(client);
    avahi_simple_poll_free(simple_poll);
    g_print("mDNS unregistered!\n");
}