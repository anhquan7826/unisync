import 'dart:convert';
import 'dart:typed_data';

extension UInt8List on Uint8List {
  String get string => const Utf8Decoder().convert(this);
}
