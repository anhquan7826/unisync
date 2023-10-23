import 'package:uuid/uuid.dart';

String generateId() {
  const uuid = Uuid();
  final randomUuid = uuid.v4();
  return randomUuid.replaceAll('-', '');
}