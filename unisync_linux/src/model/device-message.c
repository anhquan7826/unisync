#include "device-message.h"

struct _UMessage
{
    GObject parent;

    long time;
    const gchar *type;
    UMessageHeader *header;
    UMessagePayload *payload;
    GHashTable *body;
};

struct _UMessageHeader
{
    GObject parent;

    const char *type;
    const char *method;
    const char *status;
};

struct _UMessagePayload
{
    GObject parent;

    int port;
    long size;
};

G_DEFINE_TYPE(UMessage, u_message, G_TYPE_OBJECT)
G_DEFINE_TYPE(UMessageHeader, u_message_header, G_TYPE_OBJECT)
G_DEFINE_TYPE(UMessagePayload, u_message_payload, G_TYPE_OBJECT)

#define PROP_MESSAGE_TIME 1
GParamSpec *message_time_pspec;

#define PROP_MESSAGE_TYPE 2
GParamSpec *message_type_pspec;

#define PROP_MESSAGE_HEADER 3
GParamSpec *message_header_pspec;

#define PROP_MESSAGE_PAYLOAD 4
GParamSpec *message_payload_pspec;

#define PROP_MESSAGE_BODY 5
GParamSpec *message_body_pspec;

#define PROP_MESSAGE_HEADER_TYPE 1
GParamSpec *message_header_type_pspec;

#define PROP_MESSAGE_HEADER_METHOD 2
GParamSpec *message_header_method_pspec;

#define PROP_MESSAGE_HEADER_STATUS 3
GParamSpec *message_header_status_pspec;

#define PROP_MESSAGE_PAYLOAD_PORT 1
GParamSpec *message_payload_port_pspec;

#define PROP_MESSAGE_PAYLOAD_SIZE 2
GParamSpec *message_payload_size_pspec;

static void u_message_get_property(GObject *object, guint property_id, GValue *value, GParamSpec *pspec)
{
    UMessage *message = U_MESSAGE(object);

    switch (property_id)
    {
    case PROP_MESSAGE_TIME:
        g_value_set_long(value, message->time);
        break;
    case PROP_MESSAGE_TYPE:
        g_value_set_string(value, message->type);
        break;
    case PROP_MESSAGE_HEADER:
        g_value_set_object(value, message->header);
        break;
    case PROP_MESSAGE_PAYLOAD:
        g_value_set_object(value, message->payload);
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID(object, property_id, pspec);
        break;
    }
}

static void u_message_set_property(GObject *object, guint property_id, GValue *value, GParamSpec *pspec)
{
    UMessage *message = U_MESSAGE(object);

    switch (property_id)
    {
    case PROP_MESSAGE_TIME:
        message->time = g_value_get_long(value);
        break;
    case PROP_MESSAGE_TYPE:
        message->type = g_value_get_string(value);
        break;
    case PROP_MESSAGE_HEADER:
        message->header = U_MESSAGE_HEADER(g_value_get_object(value));
        break;
    case PROP_MESSAGE_PAYLOAD:
        message->payload = U_MESSAGE_PAYLOAD(g_value_get_object(value));
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID(object, property_id, pspec);
        break;
    }
}

static void u_message_class_init(UMessageClass *klass)
{
    GObjectClass *gobject_class = G_OBJECT_CLASS(klass);
    gobject_class->get_property = u_message_get_property;
    gobject_class->set_property = u_message_set_property;
    message_time_pspec = g_param_spec_long("time", "time", "Message timestamp", 0, G_MAXLONG, 0, G_PARAM_READWRITE);
    message_type_pspec = g_param_spec_string("type", "type", "Message type", NULL, G_PARAM_READWRITE);
    message_header_pspec = g_param_spec_object("header", "header", "Messager header", U_TYPE_MESSAGE_HEADER, G_PARAM_READWRITE);
    message_payload_pspec = g_param_spec_object("payload", "payload", "Message payload", U_TYPE_MESSAGE_PAYLOAD, G_PARAM_READWRITE);
    message_body_pspec = g_param_spec_hash("body", "body", "Message body", G_TYPE_STRING, G_TYPE_VARIANT, G_PARAM_READABLE);
    g_object_class_install_property(gobject_class, PROP_MESSAGE_TIME, message_time_pspec);
    g_object_class_install_property(gobject_class, PROP_MESSAGE_TYPE, message_type_pspec);
    g_object_class_install_property(gobject_class, PROP_MESSAGE_HEADER, message_header_pspec);
    g_object_class_install_property(gobject_class, PROP_MESSAGE_PAYLOAD, message_payload_pspec);
}

static void u_message_init(UMessage *message)
{
    message->header = NULL;
    message->payload = NULL;
}

static void u_message_header_get_property(GObject *object, guint property_id, GValue *value, GParamSpec *pspec)
{
    UMessageHeader *header = U_MESSAGE_HEADER(object);

    switch (property_id)
    {
        case PROP_MESSAGE_HEADER_TYPE:
            g_value_set_string(value, header->type);
            break;
        case PROP_MESSAGE_HEADER_METHOD:
            g_value_set_string(value, header->method);
            break;
        case PROP_MESSAGE_HEADER_STATUS:
            g_value_set_string(value, header->status);
            break;
        default:
            G_OBJECT_WARN_INVALID_PROPERTY_ID(object, property_id, pspec);
            break;
    }
}

static void u_message_header_set_property(GObject *object, guint property_id, GValue *value, GParamSpec *pspec)
{
    UMessageHeader *header = U_MESSAGE_HEADER(object);

    switch (property_id)
    {
        case PROP_MESSAGE_HEADER_TYPE:
            header->type = g_value_get_string(value);
            break;
        case PROP_MESSAGE_HEADER_METHOD:
            header->method = g_value_get_string(value);
            break;
        case PROP_MESSAGE_HEADER_STATUS:
            header->status = g_value_get_string(value);
            break;
        default:
            G_OBJECT_WARN_INVALID_PROPERTY_ID(object, property_id, pspec);
            break;
    }
}

static void u_message_header_class_init(UMessageHeaderClass *klass)
{
    GObjectClass *object_class = G_OBJECT_CLASS(klass);
    object_class->get_property = u_message_header_get_property;
    object_class->set_property = u_message_header_set_property;
    message_header_type_pspec = g_param_spec_string("type", "type", "Message header type", U_MESSAGE_HEADER_TYPE_REQUEST, G_PARAM_READWRITE);
    message_header_method_pspec = g_param_spec_string("method", "method", "Message header method", NULL, G_PARAM_READWRITE);
    message_header_status_pspec = g_param_spec_string("status", "status", "Message header status", NULL, G_PARAM_READWRITE);
    g_object_class_install_property(object_class, PROP_MESSAGE_HEADER_TYPE, message_header_type_pspec);
    g_object_class_install_property(object_class, PROP_MESSAGE_HEADER_METHOD, message_header_method_pspec);
    g_object_class_install_property(object_class, PROP_MESSAGE_HEADER_STATUS, message_header_status_pspec);
}

static void u_message_header_init(UMessageHeader *header)
{
    header->type = U_MESSAGE_HEADER_TYPE_REQUEST;
    header->method = NULL;
    header->status = NULL;
}

static void u_message_payload_get_property(GObject *object, guint property_id, GValue *value, GParamSpec *pspec)
{
    UMessagePayload *payload = U_MESSAGE_PAYLOAD(object);

    switch (property_id)
    {
        case PROP_MESSAGE_PAYLOAD_PORT:
            g_value_set_int(value, payload->port);
            break;
        case PROP_MESSAGE_PAYLOAD_SIZE:
            g_value_set_int(value, payload->size);
            break;
        default:
            G_OBJECT_WARN_INVALID_PROPERTY_ID(object, property_id, pspec);
            break;
    }
}

static void u_message_payload_set_property(GObject *object, guint property_id, GValue *value, GParamSpec *pspec)
{
    UMessagePayload *payload = U_MESSAGE_PAYLOAD(object);

    switch (property_id)
    {
        case PROP_MESSAGE_PAYLOAD_PORT:
            payload->port = g_value_get_int(value);
            break;
        case PROP_MESSAGE_PAYLOAD_SIZE:
            payload->size = g_value_get_int(value);
            break;
        default:
            G_OBJECT_WARN_INVALID_PROPERTY_ID(object, property_id, pspec);
            break;
    }
}

static void u_message_payload_class_init(UMessagePayloadClass *klass)
{
    GObjectClass *object_class = G_OBJECT_CLASS(klass);
    object_class->get_property = u_message_payload_get_property;
    object_class->set_property = u_message_payload_set_property;
    message_payload_port_pspec = g_param_spec_int("port", "port", "Message payload port", 0, 65535, 0, G_PARAM_READWRITE);
    message_payload_size_pspec = g_param_spec_long("size", "size", "Message payload size", 0, G_MAXLONG, 0, G_PARAM_READWRITE);
    g_object_class_install_property(object_class, PROP_MESSAGE_PAYLOAD_PORT, message_payload_port_pspec);
    g_object_class_install_property(object_class, PROP_MESSAGE_PAYLOAD_SIZE, message_payload_size_pspec);
}

static void u_message_payload_init(UMessagePayload *payload)
{}

UMessage *u_message_new_with_values(int time, const gchar *type, const gchar *body, UMessageHeader *header, UMessagePayload *payload)
{
    UMessage *message = g_object_new(U_TYPE_MESSAGE, NULL);
    message->time = time;
    message->header = header;
    message->payload = payload;
    // TODO: Convert body into a GHashTable and store it in the message.
    return message;
}

UMessageHeader u_message_header_new_with_values(const gchar *type, const gchar *method, const gchar *status);

UMessagePayload u_message_payload_new_with_values(int port, int size);

const char *u_message_to_json(UMessage *self);

UMessage *u_message_new_from_json(char *json);