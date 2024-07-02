#pragma once

#include <stdio.h>
#include <avahi-client/publish.h>
#include <avahi-common/simple-watch.h>

void mdns_registration_new(const char* _name, const char* _type, const char* _domain, int _port);

void mdns_registration_free();