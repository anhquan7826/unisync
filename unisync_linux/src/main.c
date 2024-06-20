#include <stdio.h>
#include <gtk/gtk.h>

static void activate(GtkApplication *app, gpointer userdata) 
{
    GtkWidget *window;
    GtkWidget *window_alt;

    window = gtk_application_window_new(app);
    window_alt = gtk_window_new();

    gtk_window_set_default_size(GTK_WINDOW(window), 200, 200);
    gtk_window_set_default_size(GTK_WINDOW(window_alt), 200, 200);

    gtk_window_set_title(GTK_WINDOW(window), "Window 1");
    gtk_window_set_title(GTK_WINDOW(window_alt), "Window 2");

    gtk_window_set_transient_for(GTK_WINDOW(window_alt), GTK_WINDOW(window));
    gtk_window_set_destroy_with_parent(GTK_WINDOW(window_alt), true);

    gtk_window_present(GTK_WINDOW(window));
    gtk_window_present(GTK_WINDOW(window_alt));
}

int main(int argc, char **argv)
{
    GtkApplication *app;
    int status;

    app = gtk_application_new("com.anhquan.unisync", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);
    return status;
}
