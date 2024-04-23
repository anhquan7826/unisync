import 'dart:convert';

extension MapExtension on Map {
  String toJsonString() {
    return jsonEncode(this);
  }
}
