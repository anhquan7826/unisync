cmake_minimum_required(VERSION 3.28)
project(unisync_linux)
set(CMAKE_CXX_STANDARD 17)

include_directories(include)
file(GLOB_RECURSE SOURCE src/*.c)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED gtk4)
include_directories(${GTK_INCLUDE_DIRS})
link_directories(${GTK_LIBRARY_DIRS})

add_executable(unisync_linux ${SOURCE})
target_link_libraries(unisync_linux ${GTK_LIBRARIES})