import 'dart:typed_data';

List<List<int>> mapToTxtRecord(Map<String, dynamic> map) {
  final List<List<int>> aay = [];
  final strings = [];
  for (final entry in map.entries) {
    strings.add('${entry.key}=${entry.value}');
  }
  for (final String s in strings) {
    aay.add(Uint8List.fromList(s.codeUnits));
  }
  print(aay);
  return aay;
}
