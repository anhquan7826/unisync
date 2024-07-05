#include "socket-util.h"

#define CHUNK_SIZE 4096

typedef struct {
    GInputStream *in_stream;
    OnInputStreamData cb;
} ThreadData;

static gpointer _thread_func(gpointer data)
{
    ThreadData *thread_data = (ThreadData *) data;
    GInputStream *in_stream = G_INPUT_STREAM(thread_data->in_stream);
    OnInputStreamData cb = thread_data->cb;
    gsize *bytes_read = malloc(sizeof(gsize));
    guint8 *buffer = malloc(sizeof(guint8) * CHUNK_SIZE);
    GError *error = NULL;
    while (TRUE)
    {
        if (g_input_stream_read_all(in_stream, buffer, CHUNK_SIZE, bytes_read, NULL, &error))
        {
            if (*bytes_read == 0) continue;
            guint8 *trimmed = malloc(*bytes_read);
            memcpy(trimmed, buffer, *bytes_read);
            g_print("Received data: %s", trimmed);
            cb((const char *)trimmed);
        }
        else
        {
            g_printerr("Error reading data: %s\n", error->message);
            break;
        }
    }
    g_print("Input stream closed!");
    g_free(thread_data);
    g_object_unref(in_stream);
    g_free(cb);
    g_free(bytes_read);
    g_free(buffer);
    g_error_free(error);
}

GThread *util_socket_read_input_stream(GSocketConnection *connection, OnInputStreamData cb)
{
    GSocketAddress *socket_address = g_socket_connection_get_remote_address(connection, NULL);
    gchar *address = g_socket_connectable_to_string(G_SOCKET_CONNECTABLE(socket_address));
    GInputStream *in_stream = g_io_stream_get_input_stream(G_IO_STREAM(connection));
    ThreadData *thread_data = malloc(sizeof(ThreadData));
    thread_data->in_stream = in_stream;
    thread_data->cb = cb;
    GThread *thread = g_thread_new(address, _thread_func, thread_data);
    return thread;
}