import 'dart:convert';
import 'package:data_cache_x/serializers/data_serializer.dart';

/// A [DataSerializer] that uses JSON for serialization.
class JsonDataSerializer<T> implements DataSerializer<T> {
  @override
  T deserialize(String data) {
    return json.decode(data) as T;
  }

  @override
  String serialize(T data) {
    return json.encode(data);
  }
}
