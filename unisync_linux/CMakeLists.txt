cmake_minimum_required(VERSION 3.28)
project(unisync_linux)
set(CMAKE_CXX_STANDARD 17)
set (CMAKE_PREFIX_PATH /usr/include/)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED gtk4)

pkg_search_module(UUID REQUIRED uuid)

file(GLOB_RECURSE SOURCE src/*.c)
add_executable(unisync_linux ${SOURCE})
target_include_directories(unisync_linux PRIVATE include/)

target_include_directories(unisync_linux PUBLIC ${GTK_INCLUDE_DIRS})
target_link_libraries(unisync_linux ${GTK_LIBRARIES})

target_include_directories(unisync_linux PUBLIC ${UUID_INCLUDE_DIRS})
target_link_libraries(unisync_linux ${UUID_LIBRARIES})