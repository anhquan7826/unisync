#include <json-glib/json-glib.h>

#include "json-util.h"

#define READ_ITERATE \
    JsonReader *reader = json_reader_new(json_parser_get_root(json)); \
    json_reader_read_member(reader, key); \
    va_list ap; \
    va_start(ap, key); \
    while (1) { \
        int arg = va_arg(ap, const char *); \
        if (!arg) break; \
        json_reader_read_member(reader, arg); \
    } \
    va_end(ap);

Json *util_json_read(const char *data, GError **error) {
    Json *json = json_parse_string(data, error);
    return json;
}

const char* util_json_get_string(Json *json, const char *key, ...) 
{
    READ_ITERATE
    const char *result = json_reader_get_string_value(reader);
    json_reader_free(reader);
    return result;
}

int util_json_get_int(Json *json, const char *key);

double util_json_get_double(Json *json, const char *key);

long long util_json_get_long(Json *json, const char *key);

void util_json_free(Json *json);

void util_json_print(Json *json);