cmake_minimum_required(VERSION 3.28)
project(unisync_linux)
set(CMAKE_CXX_STANDARD 17)
set (CMAKE_PREFIX_PATH /usr/include/)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED gtk4)

pkg_search_module(UUID REQUIRED uuid)
pkg_search_module(JSONGLIB REQUIRED json-glib-1.0)
pkg_search_module(AVAHI REQUIRED avahi-client)

set(
    SOURCE 
    src/main.c
    src/core/mdns.c
    src/core/socket.c
    src/core/unisync-process.c
    src/dbus/dbus-iface-device.c
    src/dbus/dbus-device.c
    src/model/device-info.c
    src/model/device-message.c
    src/utils/json-util.c
    src/utils/socket-util.c
)
add_executable(unisync_linux ${SOURCE})
target_include_directories(unisync_linux PRIVATE include/)

target_include_directories(unisync_linux PUBLIC ${GTK_INCLUDE_DIRS})
target_link_libraries(unisync_linux ${GTK_LIBRARIES})

target_include_directories(unisync_linux PUBLIC ${UUID_INCLUDE_DIRS})
target_link_libraries(unisync_linux ${UUID_LIBRARIES})

target_include_directories(unisync_linux PUBLIC ${JSONGLIB_INCLUDE_DIRS})
target_link_libraries(unisync_linux ${JSONGLIB_LIBRARIES})

target_include_directories(unisync_linux PUBLIC ${AVAHI_INCLUDE_DIRS})
target_link_libraries(unisync_linux ${AVAHI_LIBRARIES})