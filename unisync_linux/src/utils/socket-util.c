#include "socket-util.h"

#define CHUNK_SIZE 4096

typedef struct
{
    GInputStream *in_stream;
    OnInputStreamData cb;
    OnInputStreamClose on_close;
    gpointer on_close_data;
} ThreadData;

static gpointer _thread_func(gpointer data)
{
    ThreadData *thread_data = (ThreadData *)data;
    GDataInputStream *in_stream = g_data_input_stream_new(G_INPUT_STREAM(thread_data->in_stream));
    OnInputStreamData cb = thread_data->cb;
    OnInputStreamClose on_close = thread_data->on_close;
    gpointer on_close_data = thread_data->on_close_data;
    GError *error = NULL;
    while (TRUE)
    {
        gchar *line = g_data_input_stream_read_line_utf8(in_stream, NULL, NULL, &error);
        if (error)
        {
            g_printerr("Error reading data: %s\n", error->message);
            break;
        }
        if (!line)
        {
            g_print("Input stream closed!\n");
            break;
        }
        cb((const char *)line);
    }
    on_close(on_close_data);
    g_object_unref(in_stream);
    if (error)
        g_error_free(error);
    g_free(thread_data);
}

GThread *util_socket_read_input_stream(GSocketConnection *connection, OnInputStreamData cb, OnInputStreamClose on_close, gpointer on_close_data)
{
    GSocketAddress *socket_address = g_socket_connection_get_remote_address(connection, NULL);
    gchar *address = g_socket_connectable_to_string(G_SOCKET_CONNECTABLE(socket_address));
    GInputStream *in_stream = g_io_stream_get_input_stream(G_IO_STREAM(connection));
    ThreadData *thread_data = malloc(sizeof(ThreadData));
    thread_data->in_stream = in_stream;
    thread_data->cb = cb;
    thread_data->on_close = on_close;
    thread_data->on_close_data = on_close_data;
    GThread *thread = g_thread_new(address, _thread_func, thread_data);
    return thread;
}

GDataOutputStream *util_socket_get_output_stream(GSocketConnection *connection)
{
    GOutputStream *out_stream = g_io_stream_get_output_stream(G_IO_STREAM(connection));
    GDataOutputStream *out = g_data_output_stream_new(out_stream);
    return out;
}