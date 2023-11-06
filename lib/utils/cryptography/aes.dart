import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

class AESHelper {
  AESHelper._();

  static Uint8List encrypt(Uint8List data, {required Key secretKey}) {
    final encrypter = Encrypter(AES(secretKey, mode: AESMode.cbc, padding: 'PKCS5'));
    return encrypter.encryptBytes(data, iv: IV.fromLength(16)).bytes;
  }

  static Uint8List decrypt(Uint8List data, {required Key secretKey}) {
    final encrypter = Encrypter(AES(secretKey, mode: AESMode.cbc, padding: 'PKCS5'));
    return Uint8List.fromList(encrypter.decryptBytes(Encrypted.fromBase64(base64.encode(data)), iv: IV.fromLength(16)));
  }
}
