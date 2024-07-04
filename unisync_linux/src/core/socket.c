#include "socket.h"
#include <glib/gthread.h>

void socket_server_init(OnNewSocketCallback cb)
{
    g_print("Creating server socket...\n");
    GError *error = NULL;
    GSocket *socket;
    socket = G_SOCKET(g_socket_new(G_SOCKET_FAMILY_IPV4, G_SOCKET_TYPE_STREAM, G_SOCKET_PROTOCOL_TCP, &error));
    if (error)
    {
        g_printerr("Error: Cannot create server socket:\n%s\n", error->message);
        exit(1);
    }
    g_print("Server socket created. Binding...\n");
    GSocketAddress *socket_address = G_SOCKET_ADDRESS(g_inet_socket_address_new_from_string("localhost", 12345));
    g_socket_bind(
        socket, 
        socket_address, 
        TRUE,
        &error
    );
    if (error)
    {
        g_printerr("Error: Cannot bind server socket:\n%s\n", error->message);
        exit(1);
    }
    g_print("Server socket bound. Start listening...\n");
    g_socket_listen(socket, &error);
    if (error)
    {
        g_printerr("Error: Cannot listen to server socket:\n%s\n", error->message);
        exit(1);
    }
    while (1) {
        GSocket *new_socket = g_socket_accept(socket, NULL, &error);
        if (error) {
            exit(1);
            g_printerr("Error: Cannot accept socket:\n%s\n", error->message);
        }
        cb(new_socket);
    }
}