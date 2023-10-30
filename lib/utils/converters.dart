import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/asymmetric/api.dart';

RSAPublicKey publicKeyFromPEM(String key) {
  key
    ..replaceAll('-----BEGIN RSA PUBLIC KEY-----', '')
    ..replaceAll('-----END RSA PUBLIC KEY-----', '');
  final parser = RSAKeyParser().parse('-----BEGIN RSA PUBLIC KEY-----\n$key\n-----END RSA PUBLIC KEY-----');
  return RSAPublicKey(parser.modulus!, parser.exponent!);
}

RSAPrivateKey privateKeyFromPEM(String key) {
  key
    ..replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
    ..replaceAll('-----END RSA PRIVATE KEY-----', '');
  final parser = RSAKeyParser().parse('-----BEGIN RSA PRIVATE KEY-----\n$key\n-----END RSA PRIVATE KEY-----') as RSAPrivateKey;
  return RSAPrivateKey(parser.modulus!, parser.exponent!, parser.p, parser.q);
}

String rsaKeyToPEM({RSAPublicKey? publicKey, RSAPrivateKey? privateKey}) {
  if (publicKey != null) {
    final sequence = ASN1Sequence()
      ..add(ASN1Integer(publicKey.exponent!))
      ..add(ASN1Integer(publicKey.modulus))
      ..encode();
    return base64Encode(sequence.encodedBytes!);
  }
  if (privateKey != null) {
    final sequence = ASN1Sequence()
      ..add(ASN1Integer(privateKey.exponent!))
      ..add(ASN1Integer(privateKey.modulus))
      ..add(ASN1Integer(privateKey.p))
      ..add(ASN1Integer(privateKey.q))
      ..encode();
    return base64Encode(sequence.encodedBytes!);
  }
  return '';
}
