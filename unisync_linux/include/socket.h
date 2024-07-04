#pragma once
#include <gio/gio.h>

typedef void (*OnNewSocketCallback) (GSocket *);

void socket_server_init(OnNewSocketCallback cb);