gdbus-codegen \
    --interface-prefix=com.anhquan.UnisyncDbus1 \
    --c-namespace UnisyncDbus \
    --header \
    --output ../../include/dbus-iface-device.h \
    --pragma-once \
    v1/com.anhquan.UnisyncDbus.Device.xml

gdbus-codegen \
    --interface-prefix=com.anhquan.UnisyncDbus1 \
    --c-namespace UnisyncDbus \
    --body \
    --output ../../src/dbus/dbus-iface-device.c \
    v1/com.anhquan.UnisyncDbus.Device.xml