#include "my_application.h"
#include <flutter_linux/flutter_linux.h>
#include "plugins/mdns/mdns.h"
#include "plugins/clipboard/clipboard.h"

#ifdef GDK_WINDOWING_X11

#include <gdk/gdkx.h>

#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
    GtkApplication parent_instance;
    char **dart_entrypoint_arguments;
    FlMethodChannel *mdns_channel;
    FlMethodChannel *clipboard_channel;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

void clipboard_call_handler(FlMethodChannel *channel,
                            FlMethodCall *method_call,
                            gpointer user_data) {
    g_autoptr(FlMethodResponse) response = nullptr;
    if (strcmp(fl_method_call_get_name(method_call), "get") == 0) {
        gchar *result = get_clipboard();
        response = FL_METHOD_RESPONSE(
                fl_method_success_response_new(
                        fl_value_new_string(
                                static_cast<gchar *> (result)
                        )
                )
        );
    }
    if (strcmp(fl_method_call_get_name(method_call), "set") == 0) {
        FlValue *value = fl_method_call_get_args(method_call);
        const char *content = fl_value_get_string(value);
        set_clipboard(content);
        response = FL_METHOD_RESPONSE(
                fl_method_success_response_new(
                        fl_value_new_bool(
                                static_cast<bool> (true)
                        )
                )
        );
    }
    g_autoptr(GError) error = nullptr;
    if (!fl_method_call_respond(method_call, response, &error)) {
        g_warning("Failed to send response: %s", error->message);
    }
}

void mdns_call_handler(FlMethodChannel *channel,
                       FlMethodCall *method_call,
                       gpointer user_data) {
    g_autoptr(FlMethodResponse) response = nullptr;
    if (strcmp(fl_method_call_get_name(method_call), "register") == 0) {
        g_print("Registering Avahi Service...\n");
        service_registration_new("unisync@linux", "_unisync._tcp", "local", 50810);
        response = FL_METHOD_RESPONSE(
                fl_method_success_response_new(
                        fl_value_new_bool(
                                static_cast<bool>(true)
                        )
                )
        );
    }
    g_autoptr(GError) error = nullptr;
    if (!fl_method_call_respond(method_call, response, &error)) {
        g_warning("Failed to send response: %s", error->message);
    }
}

// Implements GApplication::activate.
static void my_application_activate(GApplication *application) {
    MyApplication *self = MY_APPLICATION(application);
    GtkWindow *window =
            GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

    gtk_window_set_title(window, "unisync");
    gtk_window_set_default_size(window, 1280, 720);
    gtk_widget_show(GTK_WIDGET(window));

    g_autoptr(FlDartProject) project = fl_dart_project_new();
    fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

    FlView *view = fl_view_new(project);
    gtk_widget_show(GTK_WIDGET(view));
    gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

    g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
    fl_register_plugins(FL_PLUGIN_REGISTRY(view));

    // DEFINE CHANNELS
    self->mdns_channel = fl_method_channel_new(
            fl_engine_get_binary_messenger(fl_view_get_engine(view)),
            "com.anhquan.unisync/mdns", FL_METHOD_CODEC(codec));
    self->clipboard_channel = fl_method_channel_new(
            fl_engine_get_binary_messenger(fl_view_get_engine(view)),
            "com.anhquan.unisync/clipboard", FL_METHOD_CODEC(codec));

    // REGISTER HANDLERS
    fl_method_channel_set_method_call_handler(
            self->mdns_channel, mdns_call_handler, self, nullptr);
    fl_method_channel_set_method_call_handler(
            self->clipboard_channel, clipboard_call_handler, self, nullptr);

    gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication *application, gchar ***arguments, int *exit_status) {
    MyApplication *self = MY_APPLICATION(application);
    // Strip out the first argument as it is the binary name.
    self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

    g_autoptr(GError) error = nullptr;
    if (!g_application_register(application, nullptr, &error)) {
        g_warning("Failed to register: %s", error->message);
        *exit_status = 1;
        return TRUE;
    }

    g_application_activate(application);
    *exit_status = 0;

    return TRUE;
}

// Implements GObject::dispose.
static void my_application_dispose(GObject *object) {
    MyApplication *self = MY_APPLICATION(object);
    g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
    g_clear_object(&self->mdns_channel);
    g_clear_object(&self->clipboard_channel);
    G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass *klass) {
    G_APPLICATION_CLASS(klass)->activate = my_application_activate;
    G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
    G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication *self) {}

MyApplication *my_application_new() {
    return MY_APPLICATION(g_object_new(my_application_get_type(),
                                       "application-id", APPLICATION_ID,
                                       "flags", G_APPLICATION_NON_UNIQUE,
                                       nullptr));
}
