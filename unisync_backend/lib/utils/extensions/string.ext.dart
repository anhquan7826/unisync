import 'dart:convert';

extension StringExtension on String {
  Map<String, dynamic> toMap() {
    return jsonDecode(this);
  }
}