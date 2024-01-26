// ignore_for_file: constant_identifier_names

class AvahiServerState {
  AvahiServerState._();

  static const AVAHI_SERVER_INVALID = 0;
  static const AVAHI_SERVER_REGISTERING = 1;
  static const AVAHI_SERVER_RUNNING = 2;
  static const AVAHI_SERVER_COLLISION = 3;
  static const AVAHI_SERVER_FAILURE = 4;
}

class AvahiEntryGroupState {
  AvahiEntryGroupState._();

  static const AVAHI_ENTRY_GROUP_UNCOMMITED = 0;
  static const AVAHI_ENTRY_GROUP_REGISTERING = 1;
  static const AVAHI_ENTRY_GROUP_ESTABLISHED = 2;
  static const AVAHI_ENTRY_GROUP_COLLISION = 3;
  static const AVAHI_ENTRY_GROUP_FAILURE = 4;
}

class AvahiResolverState {
  AvahiResolverState._();
  
  static const AVAHI_RESOLVER_FOUND = 0;
  static const AVAHI_RESOLVER_FAILURE = 1;
}
