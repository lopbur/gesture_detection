import 'dart:math';
import 'dart:typed_data';

bool mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null || a.length != b.length) {
    return false;
  }
  for (var key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) {
      return false;
    }
  }
  return true;
}

Future<String> getSize(Uint8List data) async {
  int bytes = data.lengthInBytes;
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(3)} ${suffixes[i]}';
}
