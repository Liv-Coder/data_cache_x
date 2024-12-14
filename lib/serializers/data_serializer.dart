/// An interface for serializing and deserializing data.
abstract class DataSerializer<T> {
  /// Serializes the given data into a string.
  String serialize(T data);

  /// Deserializes the given string into an object of type T.
  T deserialize(String data);
}
