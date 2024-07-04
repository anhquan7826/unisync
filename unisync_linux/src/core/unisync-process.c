#include "unisync-process.h"
#include <glib/gthread.h>
#include <gio/gio.h>

static GThread *process_thread;

static void on_new_socket_connection(GSocket *socket) 
{
    GInetSocketAddress *socket_address = G_INET_SOCKET_ADDRESS(g_socket_get_remote_address(socket, NULL));
    GInetAddress *address = g_inet_socket_address_get_address(socket_address);
    g_print("Connected: %s\n", g_inet_address_to_string(address));
}

static gpointer start(gpointer data) {
    mdns_registration_new("unisync", "_unisync._tcp", "local", 50810);
    socket_server_init(on_new_socket_connection);
}


void run_process()
{
    process_thread = g_thread_new("unisync_process", start, NULL);
    g_thread_join(process_thread);
}