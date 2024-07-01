#include "json-util.h"

#define READER_ITERATE \
    JsonReader *reader = json_reader_new(json); \
    json_reader_read_member(reader, key); \
    va_list ap; \
    va_start(ap, key); \
    while (1) { \
        int arg = va_arg(ap, const char *); \
        if (!arg) break; \
        json_reader_read_member(reader, arg); \
    } \
    va_end(ap);

#define READER_FREE \
    json_reader_free(reader);

void _util_json_print_foreach(
    JsonObject  *object,
    const gchar *member_name,
    JsonNode    *member_node,
    gpointer     user_data
)
{
    g_print("  \"%s\": ", member_name);
    if (JSON_NODE_HOLDS_OBJECT(member_node)) {
        g_print("{\n");
        util_json_print(json_node_get_object(member_node));
        g_print("  }");
    } else if (JSON_NODE_HOLDS_ARRAY(member_node)) {
        g_print("[\n");
        JsonArray *array = json_node_get_array(member_node);
        guint length = json_array_get_length(array);
        for (guint i = 0; i < length; i++) {
            JsonNode *element = json_array_get_element(array, i);
            if (JSON_NODE_HOLDS_OBJECT(element)) {
                g_print("    {\n");
                util_json_print(json_node_get_object(element));
                g_print("    }");
            } else if (JSON_NODE_HOLDS_ARRAY(element)) {
                g_print("    [\n");
                util_json_print(json_node_get_object(element));
                g_print("    ]");
            } else {
                g_print("    %s", json_to_string(element, FALSE));
            }
            if (i < length - 1) {
                g_print(",\n");
            } else {
                g_print("\n");
            }
        }
        g_print("  ]");
    } else {
        g_print("%s", json_to_string(member_node, FALSE));
    }
    g_print(",\n");
}

void util_json_print(JsonObject *json)
{
    json_object_foreach_member(json, _util_json_print_foreach, NULL);
}