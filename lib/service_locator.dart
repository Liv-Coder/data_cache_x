import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/adapters/hive/hive_adapter.dart';
import 'package:data_cache_x/adapters/memory_adapter.dart';
import 'package:data_cache_x/adapters/sqlite/sqlite_adapter.dart';
import 'package:data_cache_x/adapters/shared_preferences/shared_preferences_adapter.dart';
import 'package:data_cache_x/core/data_cache_x.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:data_cache_x/serializers/data_serializer.dart';
import 'package:data_cache_x/serializers/json_data_serializer.dart';
import 'package:data_cache_x/utils/background_cleanup.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum CacheAdapterType {
  hive,
  memory,
  sqlite,
  sharedPreferences,
}

final getIt = GetIt.instance;

class TypeAdapterRegistry {
  static final TypeAdapterRegistry _instance = TypeAdapterRegistry._internal();

  factory TypeAdapterRegistry() {
    return _instance;
  }

  TypeAdapterRegistry._internal();

  final Map<Type, TypeAdapter> _adapters = {};
  final Map<Type, DataSerializer> _serializers = {};

  void registerAdapter<T>(TypeAdapter<T> adapter,
      {int? typeId, TypeAdapter<CacheItem<T>>? cacheItemAdapter}) {
    if (typeId != null) {
      _adapters[T] =
          _CacheItemAdapter<T>(typeId: typeId, valueAdapter: adapter);
    } else {
      _adapters[T] = adapter;
    }
    if (cacheItemAdapter != null) {
      _adapters[CacheItem<T>] = cacheItemAdapter;
    }
  }

  void registerSerializer<T>(DataSerializer<T> serializer) {
    _serializers[T] = serializer;
  }

  TypeAdapter<CacheItem<T>>? getAdapter<T>() {
    final adapter = _adapters[CacheItem<T>];
    if (adapter == null) {
      return null;
    }
    return adapter as TypeAdapter<CacheItem<T>>;
  }

  TypeAdapter<T>? getValueAdapter<T>() {
    final adapter = _adapters[T];
    if (adapter == null) {
      return null;
    }
    return adapter as TypeAdapter<T>;
  }

  DataSerializer<T>? getSerializer<T>() {
    final serializer = _serializers[T];
    if (serializer == null) {
      return null;
    }
    return serializer as DataSerializer<T>;
  }
}

class JsonTypeAdapter<T> extends TypeAdapter<T> {
  final JsonDataSerializer<T> serializer;
  @override
  final int typeId;

  JsonTypeAdapter({required this.serializer, required this.typeId});

  @override
  T read(BinaryReader reader) {
    final value = reader.read() as String;
    return serializer.deserialize(value);
  }

  @override
  void write(BinaryWriter writer, T obj) {
    writer.write(serializer.serialize(obj));
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      other is JsonTypeAdapter && typeId == other.typeId;
}

Future<void> setupDataCacheX({
  String? boxName,
  Duration? cleanupFrequency,
  CacheAdapterType adapterType = CacheAdapterType.hive,
  bool enableEncryption = false,
  String? encryptionKey,
  Map<Type, TypeAdapter<CacheItem>>? customAdapters,
  Map<Type, DataSerializer>? customSerializers,
}) async {
  // Register TypeAdapterRegistry
  getIt.registerSingleton<TypeAdapterRegistry>(TypeAdapterRegistry());

  // Initialize Hive
  if (adapterType == CacheAdapterType.hive) {
    await Hive.initFlutter();
  }

  // Register default adapters
  final typeAdapterRegistry = getIt<TypeAdapterRegistry>();

  // Register custom adapters
  if (customAdapters != null) {
    customAdapters.forEach((type, adapter) {
      typeAdapterRegistry.registerAdapter(adapter);
      if (adapterType == CacheAdapterType.hive) {
        Hive.registerAdapter(adapter);
      }
    });
  }

  // Register default cache item adapters
  typeAdapterRegistry.registerAdapter<String>(
    JsonTypeAdapter<String>(
        serializer: JsonDataSerializer<String>(), typeId: 1),
    typeId: 1,
    cacheItemAdapter: _CacheItemAdapter<String>(
        typeId: 1, valueAdapter: typeAdapterRegistry.getValueAdapter<String>()),
  );
  if (adapterType == CacheAdapterType.hive) {
    Hive.registerAdapter(_CacheItemAdapter<String>(
        typeId: 1,
        valueAdapter: typeAdapterRegistry.getValueAdapter<String>()));
  }
  typeAdapterRegistry.registerAdapter<int>(
    JsonTypeAdapter<int>(serializer: JsonDataSerializer<int>(), typeId: 2),
    typeId: 2,
    cacheItemAdapter: _CacheItemAdapter<int>(
        typeId: 2, valueAdapter: typeAdapterRegistry.getValueAdapter<int>()),
  );
  if (adapterType == CacheAdapterType.hive) {
    Hive.registerAdapter(_CacheItemAdapter<int>(
        typeId: 2, valueAdapter: typeAdapterRegistry.getValueAdapter<int>()));
  }
  typeAdapterRegistry.registerAdapter<double>(
    JsonTypeAdapter<double>(
        serializer: JsonDataSerializer<double>(), typeId: 3),
    typeId: 3,
    cacheItemAdapter: _CacheItemAdapter<double>(
        typeId: 3, valueAdapter: typeAdapterRegistry.getValueAdapter<double>()),
  );
  if (adapterType == CacheAdapterType.hive) {
    Hive.registerAdapter(_CacheItemAdapter<double>(
        typeId: 3,
        valueAdapter: typeAdapterRegistry.getValueAdapter<double>()));
  }
  typeAdapterRegistry.registerAdapter<bool>(
    JsonTypeAdapter<bool>(serializer: JsonDataSerializer<bool>(), typeId: 4),
    typeId: 4,
    cacheItemAdapter: _CacheItemAdapter<bool>(
        typeId: 4, valueAdapter: typeAdapterRegistry.getValueAdapter<bool>()),
  );
  if (adapterType == CacheAdapterType.hive) {
    Hive.registerAdapter(_CacheItemAdapter<bool>(
        typeId: 4, valueAdapter: typeAdapterRegistry.getValueAdapter<bool>()));
  }
  typeAdapterRegistry.registerAdapter<List<String>>(
    JsonTypeAdapter<List<String>>(
        serializer: JsonDataSerializer<List<String>>(), typeId: 5),
    typeId: 5,
    cacheItemAdapter: _CacheItemAdapter<List<String>>(
        typeId: 5,
        valueAdapter: typeAdapterRegistry.getValueAdapter<List<String>>()),
  );
  if (adapterType == CacheAdapterType.hive) {
    Hive.registerAdapter(_CacheItemAdapter<List<String>>(
        typeId: 5,
        valueAdapter: typeAdapterRegistry.getValueAdapter<List<String>>()));
  }
  typeAdapterRegistry.registerAdapter<Map<String, dynamic>>(
    JsonTypeAdapter<Map<String, dynamic>>(
        serializer: JsonDataSerializer<Map<String, dynamic>>(), typeId: 6),
    typeId: 6,
    cacheItemAdapter: _CacheItemAdapter<Map<String, dynamic>>(
        typeId: 6,
        valueAdapter:
            typeAdapterRegistry.getValueAdapter<Map<String, dynamic>>()),
  );
  if (adapterType == CacheAdapterType.hive) {
    Hive.registerAdapter(_CacheItemAdapter<Map<String, dynamic>>(
        typeId: 6,
        valueAdapter:
            typeAdapterRegistry.getValueAdapter<Map<String, dynamic>>()));
  }

  // Register custom serializers or default if none provided
  if (customSerializers == null || customSerializers.isEmpty) {
    typeAdapterRegistry
        .registerSerializer<String>(JsonDataSerializer<String>());
    typeAdapterRegistry.registerSerializer<int>(JsonDataSerializer<int>());
    typeAdapterRegistry
        .registerSerializer<double>(JsonDataSerializer<double>());
    typeAdapterRegistry.registerSerializer<bool>(JsonDataSerializer<bool>());
    typeAdapterRegistry
        .registerSerializer<List<String>>(JsonDataSerializer<List<String>>());
    typeAdapterRegistry.registerSerializer<Map<String, dynamic>>(
        JsonDataSerializer<Map<String, dynamic>>());
  } else {
    customSerializers.forEach((type, serializer) {
      typeAdapterRegistry.registerSerializer(serializer);
    });
  }

  // Register CacheAdapter
  CacheAdapter cacheAdapter;
  switch (adapterType) {
    case CacheAdapterType.hive:
      if (!getIt.isRegistered<HiveAdapter>()) {
        final hiveAdapter = HiveAdapter(
          typeAdapterRegistry,
          boxName: boxName,
          enableEncryption: enableEncryption,
          encryptionKey: encryptionKey,
        );
        getIt.registerSingleton<HiveAdapter>(hiveAdapter);
        cacheAdapter = hiveAdapter;
      } else {
        cacheAdapter = getIt<HiveAdapter>();
      }
      break;
    case CacheAdapterType.memory:
      if (!getIt.isRegistered<MemoryAdapter>()) {
        final memoryAdapter = MemoryAdapter(
            enableEncryption: enableEncryption, encryptionKey: encryptionKey);
        getIt.registerSingleton<MemoryAdapter>(memoryAdapter);
        cacheAdapter = memoryAdapter;
      } else {
        cacheAdapter = getIt<MemoryAdapter>();
      }
      break;
    case CacheAdapterType.sqlite:
      if (!getIt.isRegistered<SqliteAdapter>()) {
        final sqliteAdapter = SqliteAdapter(
          boxName: boxName,
          enableEncryption: enableEncryption,
          encryptionKey: encryptionKey,
        );
        getIt.registerSingleton<SqliteAdapter>(sqliteAdapter);
        cacheAdapter = sqliteAdapter;
      } else {
        cacheAdapter = getIt<SqliteAdapter>();
      }
      break;
    case CacheAdapterType.sharedPreferences:
      if (!getIt.isRegistered<SharedPreferencesAdapter>()) {
        final sharedPreferencesAdapter = SharedPreferencesAdapter(
          boxName: boxName,
          enableEncryption: enableEncryption,
          encryptionKey: encryptionKey,
        );
        getIt.registerSingleton<SharedPreferencesAdapter>(
            sharedPreferencesAdapter);
        cacheAdapter = sharedPreferencesAdapter;
      } else {
        cacheAdapter = getIt<SharedPreferencesAdapter>();
      }
      break;
  }

  // Register DataCacheX
  getIt.registerSingleton<DataCacheX>(DataCacheX(cacheAdapter));

  // Initialize background cleanup
  initializeBackgroundCleanup(
    adapter: cacheAdapter,
    frequency: cleanupFrequency,
  );
}

class _CacheItemAdapter<T> extends TypeAdapter<CacheItem<T>> {
  @override
  final int typeId;
  final TypeAdapter<T>? valueAdapter;

  _CacheItemAdapter({required this.typeId, required this.valueAdapter});

  @override
  CacheItem<T> read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheItem<T>(
      value: valueAdapter != null ? valueAdapter!.read(reader) : fields[0] as T,
      expiry: fields[1] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CacheItem<T> obj) {
    writer
      ..writeByte(2)
      ..writeByte(0);
    if (valueAdapter != null) {
      valueAdapter!.write(writer, obj.value);
    } else {
      writer.write(obj.value);
    }
    writer
      ..writeByte(1)
      ..write(obj.expiry);
  }
}
