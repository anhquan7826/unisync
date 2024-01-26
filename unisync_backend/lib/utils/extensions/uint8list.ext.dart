import 'dart:typed_data';

extension UInt8List on Uint8List {
  String get string => String.fromCharCodes(this);
}