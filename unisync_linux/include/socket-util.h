#pragma once

#include <glib.h>
#include <gio/gio.h>

typedef void (* OnInputStreamData) (const char*);

typedef void (* OnInputStreamClose) (gpointer data);

GThread *util_socket_read_input_stream(GSocketConnection *connection, OnInputStreamData cb, OnInputStreamClose on_close, gpointer on_close_data);

GDataOutputStream *util_socket_get_output_stream(GSocketConnection *connection);