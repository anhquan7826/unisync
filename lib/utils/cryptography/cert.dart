import 'package:basic_utils/basic_utils.dart';
import 'package:unisync/utils/configs.dart';

Future<String> generateSelfSignedCertificate() async {
  final privKey = await ConfigUtil.authentication.getPrivateKey();
  final pubKey = await ConfigUtil.authentication.getPublicKey();
  final dn = {
    'CN': 'Self-Signed',
  };
  final csr = X509Utils.generateRsaCsrPem(dn, privKey, pubKey);

  final x509PEM = X509Utils.generateSelfSignedCertificate(
    privKey,
    csr,
    365,
  );
  return x509PEM;
}
