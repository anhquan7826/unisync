#include "unisync-process.h"
#include "socket-util.h"
#include <glib/gthread.h>
#include <gio/gio.h>

static GThread *process_thread;

static void on_stream_data(const gchar* data)
{
    g_print("%s", data);
}

static void on_new_socket_connection(GSocketConnection *socket)
{
    GSocketAddress *socket_address = g_socket_connection_get_remote_address(socket, NULL);
    gchar *address = g_socket_connectable_to_string(G_SOCKET_CONNECTABLE(socket_address));
    g_print("Connected: %s\n", address);
    g_free(address);
    g_object_unref(socket_address);
    util_socket_read_input_stream(socket, on_stream_data);
}

static gpointer start(gpointer data)
{
    mdns_registration_new("unisync", "_unisync._tcp", "local", 50810);
    socket_server_init(on_new_socket_connection);
}

void run_process()
{
    process_thread = g_thread_new("unisync_process", start, NULL);
    g_thread_join(process_thread);
}