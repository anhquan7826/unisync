import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' show RSAKeyParser;
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

class RSAHelper {
  RSAHelper._();

  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateKeypair() {
    SecureRandom getSecureRandom() {
      final secureRandom = FortunaRandom();
      final random = Random.secure();
      final List<int> seeds = [];
      for (int i = 0; i < 32; i++) {
        seeds.add(random.nextInt(256));
      }
      secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
      return secureRandom;
    }

    final keyGen = RSAKeyGenerator()..init(ParametersWithRandom(RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64), getSecureRandom()));
    final keyPair = keyGen.generateKeyPair();

    final publicKey = keyPair.publicKey as RSAPublicKey;
    final privateKey = keyPair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(publicKey, privateKey);
  }

  static String encodeRSAKey(RSAAsymmetricKey key, {bool isPrivate = false}) {
    if (isPrivate) {
      final sequence = ASN1Sequence()
        ..add(ASN1Integer((key as RSAPrivateKey).exponent!))
        ..add(ASN1Integer(key.modulus))
        ..add(ASN1Integer(key.p))
        ..add(ASN1Integer(key.q))
        ..encode();
      return base64Encode(sequence.encodedBytes!);
    } else {
      final sequence = ASN1Sequence()
        ..add(ASN1Integer((key as RSAPublicKey).exponent!))
        ..add(ASN1Integer(key.modulus))
        ..encode();
      return base64Encode(sequence.encodedBytes!);
    }
  }

  static RSAAsymmetricKey decodeRSAKey(String keyString, {bool isPrivate = false}) {
    if (isPrivate) {
      keyString = keyString
        ..replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
        ..replaceAll('-----END RSA PRIVATE KEY-----', '');
      final parser = RSAKeyParser().parse('-----BEGIN RSA PRIVATE KEY-----\n$keyString\n-----END RSA PRIVATE KEY-----') as RSAPrivateKey;
      return RSAPrivateKey(parser.modulus!, parser.exponent!, parser.p, parser.q);
    } else {
      keyString = keyString
        ..replaceAll('-----BEGIN RSA PUBLIC KEY-----', '')
        ..replaceAll('-----END RSA PUBLIC KEY-----', '');
      final parser = RSAKeyParser().parse('-----BEGIN RSA PUBLIC KEY-----\n$keyString\n-----END RSA PUBLIC KEY-----');
      return RSAPublicKey(parser.modulus!, parser.exponent!);
    }
  }

  static Uint8List encrypt(Uint8List data, RSAPublicKey publicKey) {
    final encryptor = OAEPEncoding(RSAEngine())..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    return _processInBlocks(encryptor, data);
  }

  static Uint8List decrypt(Uint8List encryptedData, RSAPrivateKey privateKey) {
    final decryptor = OAEPEncoding(RSAEngine())..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey)); // false=decrypt

    return _processInBlocks(decryptor, encryptedData);
  }

  static Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
    final numBlocks = input.length ~/ engine.inputBlockSize + ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

    final output = Uint8List(numBlocks * engine.outputBlockSize);

    var inputOffset = 0;
    var outputOffset = 0;
    while (inputOffset < input.length) {
      final chunkSize = (inputOffset + engine.inputBlockSize <= input.length) ? engine.inputBlockSize : input.length - inputOffset;

      outputOffset += engine.processBlock(input, inputOffset, chunkSize, output, outputOffset);

      inputOffset += chunkSize;
    }

    return (output.length == outputOffset) ? output : output.sublist(0, outputOffset);
  }

  static Uint8List sign(RSAPrivateKey privateKey, Uint8List dataToSign) {
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201')..init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    final sig = signer.generateSignature(dataToSign);
    return sig.bytes;
  }

  static bool verifySignature(RSAPublicKey publicKey, Uint8List signedData, Uint8List signature) {
    final sig = RSASignature(signature);
    final verifier = RSASigner(SHA256Digest(), '0609608648016503040201')..init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
    try {
      return verifier.verifySignature(signedData, sig);
      // ignore: avoid_catching_errors
    } on ArgumentError {
      return false;
    }
  }
}
