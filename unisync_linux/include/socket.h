#pragma once
#include <gio/gio.h>

typedef void (*OnNewSocketCallback) (GSocketConnection *);

void socket_server_init(OnNewSocketCallback cb);