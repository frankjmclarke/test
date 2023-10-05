import 'dart:typed_data';

class ChecksumHelper {
  static int calculateChecksum(List<String> stringList) {
    final buffer = Uint8List.fromList(stringList.join().codeUnits);
    final checksum = adler32(buffer);
    return checksum;
  }

  static int adler32(Uint8List data) {
    const modAdler = 65521;
    int a = 1, b = 0;

    for (int i = 0; i < data.length; i++) {
      a = (a + data[i]) % modAdler;
      b = (b + a) % modAdler;
    }

    return (b << 16) | a;
  }
}
