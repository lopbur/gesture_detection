import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class Uint8ListConverter implements JsonConverter<Uint8List, Object> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(Object json) {
    if (json is List<dynamic>) {
      return Uint8List.fromList(json.cast<int>());
    } else {
      throw ArgumentError('Invalid type for Uint8List: ${json.runtimeType}');
    }
  }

  @override
  Object toJson(Uint8List list) {
    return list.toList();
  }
}
