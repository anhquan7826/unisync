import 'package:basic_utils/basic_utils.dart';

class RSAHelper {
  RSAHelper._();

  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateKeypair() {
    final keyPair = CryptoUtils.generateRSAKeyPair();

    final publicKey = keyPair.publicKey as RSAPublicKey;
    final privateKey = keyPair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(publicKey, privateKey);
  }

  static String encodeRSAKey(RSAAsymmetricKey key, {bool isPrivate = false}) {

    if (isPrivate) {
      return CryptoUtils.encodeRSAPrivateKeyToPem(key as RSAPrivateKey);
    } else {
      return CryptoUtils.encodeRSAPublicKeyToPem(key as RSAPublicKey);
    }
  }

  static RSAAsymmetricKey decodeRSAKey(String keyString, {bool isPrivate = false}) {
    if (isPrivate) {
      return CryptoUtils.rsaPrivateKeyFromPem(keyString);
    } else {
      return CryptoUtils.rsaPublicKeyFromPem(keyString);
    }
  }
}
