#include "device-info.h"
#include <uuid/uuid.h>

enum {
    PROP_DEVICE_INFO_ID,
    PROP_DEVICE_INFO_NAME,
    PROP_DEVICE_INFO_TYPE,
    N_PROP_DEVICE_INFO
};

static GParamSpec *device_id_pspec = NULL;
static GParamSpec *device_name_pspec = NULL;
static GParamSpec *device_type_pspec = NULL;

struct _UDeviceInfo
{
    GObject parent_instance;

    const gchar *id;
    const gchar *name;
    const gchar *device_type;
};

G_DEFINE_TYPE(UDeviceInfo, u_device_info, G_TYPE_OBJECT)

static void u_device_info_get_property(GObject *object, guint property_id, GValue *value, GParamSpec *pspec)
{
    UDeviceInfo *self = U_DEVICE_INFO(object);
    switch (property_id)
    {
    case PROP_DEVICE_INFO_ID:
        g_value_set_string(value, self->id);
        break;

    case PROP_DEVICE_INFO_NAME:
        g_value_set_string(value, self->name);
        break;

    case PROP_DEVICE_INFO_TYPE:
        g_value_set_string(value, self->device_type);
        break;

    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID(object, property_id, pspec);
        break;
    }
}

static void u_device_info_set_property(GObject *object, guint property_id, const GValue *value, GParamSpec *pspec)
{
    UDeviceInfo *self = U_DEVICE_INFO(object);
    switch (property_id)
    {
    case PROP_DEVICE_INFO_ID:
        self->id = g_value_dup_string(value);
        break;

    case PROP_DEVICE_INFO_NAME:
        self->name = g_value_dup_string(value);
        break;

    case PROP_DEVICE_INFO_TYPE:
        self->device_type = g_value_dup_string(value);
        break;

    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID(object, property_id, pspec);
        break;
    }
}

const char* generate_new_uuid()
{
    uuid_t uuid;
    uuid_generate(uuid);
    char* str = malloc(36);
    uuid_unparse(uuid, str);
    return (const char*)str;
}

static void u_device_info_class_init(UDeviceInfoClass *klass)
{
    GObjectClass *object_class = G_OBJECT_CLASS(klass);
    object_class->get_property = u_device_info_get_property;
    object_class->set_property = u_device_info_set_property;
    device_id_pspec = g_param_spec_string("device_id", "id", "Device identification", generate_new_uuid(), G_PARAM_READWRITE);
    device_name_pspec = g_param_spec_string("device_name", "name", "Device name", "", G_PARAM_READWRITE);
    device_type_pspec = g_param_spec_string("device_type", "type", "Device type", DEVICE_TYPE_LINUX, G_PARAM_READWRITE);
    g_object_class_install_property(object_class, PROP_DEVICE_INFO_ID, device_id_pspec);
    g_object_class_install_property(object_class, PROP_DEVICE_INFO_NAME, device_name_pspec);
    g_object_class_install_property(object_class, PROP_DEVICE_INFO_TYPE, device_type_pspec);
}

static void u_device_info_init(UDeviceInfo *self) {}

UDeviceInfo* u_device_info_new_with_values (const gchar* name, const gchar* type)
{
    UDeviceInfo *o = NULL;
    o = g_object_new(
        U_TYPE_DEVICE_INFO, 
        "device_id", 
        generate_new_uuid(),
        "device_name",
        name,
        "device_type",
        type,
        NULL
    );
    return o;
}

gchar* u_device_info_to_string(UDeviceInfo *self) {
    return g_strconcat(
        "UDeviceInfo(\n\t",
        self->id,
        "\n\t",
        self->name,
        "\n\t",
        self->device_type,
        "\n)\n",
        NULL
    ); 
}

