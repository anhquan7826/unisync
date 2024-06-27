#pragma once
#include <glib-object.h>

#define U_MESSAGE_TYPE_PAIR "pair"
#define U_MESSAGE_TYPE_STATUS "status"
#define U_MESSAGE_TYPE_CLIPBOARD "clipboard"
#define U_MESSAGE_TYPE_NOTIFICATION "notification"
#define U_MESSAGE_TYPE_VOLUME "volume"
#define U_MESSAGE_TYPE_RUN_COMMAND "run_command"
#define U_MESSAGE_TYPE_RING_PHONE "ring_phone"
#define U_MESSAGE_TYPE_TELEPHONY "telephony"
#define U_MESSAGE_TYPE_SHARING "sharing"
#define U_MESSAGE_TYPE_GALLERY "gallery"
#define U_MESSAGE_TYPE_STORAGE "storage"
#define U_MESSAGE_TYPE_SSH "ssh"
#define U_MESSAGE_TYPE_MEDIA "media"

#define U_MESSAGE_HEADER_TYPE_REQUEST "request"
#define U_MESSAGE_HEADER_TYPE_RESPONSE "response"
#define U_MESSAGE_HEADER_TYPE_NOTIFICATION "notification"

#define U_MESSAGE_HEADER_STATUS_SUCCESS "success"
#define U_MESSAGE_HEADER_STATUS_ERROR "error"

#define U_TYPE_MESSAGE u_message_get_type()
G_DECLARE_FINAL_TYPE(UMessage, u_message, U, MESSAGE, GObject)

#define U_TYPE_MESSAGE_HEADER u_message_header_get_type()
G_DECLARE_FINAL_TYPE(UMessageHeader, u_message_header, U, MESSAGE_HEADER, GObject)

#define U_TYPE_MESSAGE_PAYLOAD u_message_payload_get_type()
G_DECLARE_FINAL_TYPE(UMessagePayload, u_message_payload, U, MESSAGE_PAYLOAD, GObject)

UMessage *u_message_new_with_values(int time, const gchar *type, const gchar *body, UMessageHeader *header, UMessagePayload *payload);

UMessageHeader u_message_header_new_with_values(const gchar *type, const gchar *method, const gchar *status);

UMessagePayload u_message_payload_new_with_values(int port, int size);

const char *u_message_to_json(UMessage *self);

UMessage *u_message_new_from_json(char *json);