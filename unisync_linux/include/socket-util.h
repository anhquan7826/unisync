#pragma once

#include <glib.h>
#include <gio/gio.h>

typedef void (* OnInputStreamData) (const char*);

GThread *util_socket_read_input_stream(GSocketConnection *connection, OnInputStreamData cb);