//
// Created by anhquan7826 on 1/28/24.
//

#ifndef RUNNER_MDNS_H
#define RUNNER_MDNS_H

#include "../base_header.h"
#include <avahi-client/publish.h>
#include <avahi-common/simple-watch.h>

static const char* name;
static const char* type;
static const char* domain;
static int port;

static AvahiSimplePoll *simple_poll;
static AvahiClient* client;
static AvahiEntryGroup *group;

void service_registration_new(const char* _name, const char* _type, const char* _domain, int _port);

void service_registration_free();

#endif //RUNNER_MDNS_H
