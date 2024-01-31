//
// Created by anhquan7826 on 31/01/2024.
//
#include "clipboard.h"

gchar* get_clipboard() {
    GtkClipboard *clipboard = gtk_clipboard_get(GDK_SELECTION_PRIMARY);
    gtk_main_iteration_do(FALSE);
    gchar* text = gtk_clipboard_wait_for_text(clipboard);
    return text;
}

void set_clipboard(const char* content) {
    GtkClipboard *clipboard = gtk_clipboard_get(GDK_SELECTION_PRIMARY);
    gtk_clipboard_set_text(clipboard, content, -1);
}