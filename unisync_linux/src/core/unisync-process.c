#include "unisync-process.h"
#include "socket-util.h"
#include <glib/gthread.h>
#include <gio/gio.h>

static GThread *process_thread;

static void on_stream_data(const gchar* data)
{
    g_print("%s\n", data);
}

static void on_stream_close(gpointer data)
{
    g_print("Connection closed");
}

static gpointer listen_std_in(gpointer data) 
{
    GSocketConnection *socket = G_SOCKET_CONNECTION(data);
    GDataOutputStream *out_stream = util_socket_get_output_stream(socket);
    char input[1024];
    GError *error = NULL;
    while (TRUE)
    {
        printf("> ");
        fgets(input, sizeof(input), stdin);
        input[strcspn(input, "\n")] = 0;
        g_data_output_stream_put_string(out_stream, input, NULL, &error);
        if (error)
        {
            g_printerr("Cannot write to output stream:\n%s\n", error->message);
            error = NULL;
        }
    }
}

static void on_new_socket_connection(GSocketConnection *socket)
{
    util_socket_read_input_stream(socket, on_stream_data, on_stream_close, NULL);
    GThread *thread = g_thread_new("stdin", listen_std_in, socket);
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