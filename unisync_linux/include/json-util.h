#pragma once

#include "json-glib/json-glib.h"

#define Json JsonParser

Json *util_json_read(const char *data, GError **error);

const char* util_json_get_string(Json *json, const char *key);

int util_json_get_int(Json *json, const char *key);

double util_json_get_double(Json *json, const char *key);

long long util_json_get_long(Json *json, const char *key);

void util_json_free(Json *json);

void util_json_print(Json *json);