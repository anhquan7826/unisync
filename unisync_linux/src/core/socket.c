#include "socket.h"
#include <glib/gthread.h>

void socket_server_init(OnNewSocketCallback cb)
{
    g_print("Creating server socket...\n");
    GError *error = NULL;
    GSocketListener *socket;
    socket = g_socket_listener_new();
    g_print("Server socket created. Binding...\n");
    GSocketAddress *socket_address = g_inet_socket_address_new(
        g_inet_address_new_any(G_SOCKET_FAMILY_IPV4),
        50112
    );
    g_socket_listener_add_address(
        socket,
        socket_address,
        G_SOCKET_TYPE_STREAM,
        G_SOCKET_PROTOCOL_TCP,
        NULL,
        NULL,
        &error
    );
    if (error)
    {
        g_printerr("Error: Cannot bind server socket:\n%s\n", error->message);
        exit(1);
    }
    g_print("Server socket bound. Start listening...\n");
    while (1) {
        GSocketConnection *new_socket = g_socket_listener_accept(socket, NULL, NULL, &error);
        if (error) {
            g_printerr("Error: Cannot accept socket connection:\n%s\n", error->message);
            continue;
        }
        GSocketAddress *socket_address = g_socket_connection_get_remote_address(new_socket, NULL);
        gchar *address = g_socket_connectable_to_string(G_SOCKET_CONNECTABLE(socket_address));
        g_print("Connected: %s\n", address);
        g_object_unref(socket_address);
        g_free(address);
        cb(new_socket);
    }
}