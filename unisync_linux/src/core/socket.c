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
        g_inet_address_new_loopback(G_SOCKET_FAMILY_IPV4),
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
            exit(1);
        }
        cb(new_socket);
    }
}