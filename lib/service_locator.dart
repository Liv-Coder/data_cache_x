import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/adapters/hive/hive_adapter.dart';
import 'package:data_cache_x/adapters/memory_adapter.dart';
import 'package:data_cache_x/adapters/sqlite/sqlite_adapter.dart';
import 'package:data_cache_x/adapters/shared_preferences/shared_preferences_adapter.dart';
import 'package:data_cache_x/core/data_cache_x.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:data_cache_x/models/encryption_options.dart';
import 'package:data_cache_x/serializers/data_serializer.dart';
import 'package:data_cache_x/serializers/json_data_serializer.dart';
import 'utils/background_cleanup.dart';
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
  EncryptionOptions? encryptionOptions,
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
  // First register the value adapters
  final stringAdapter = JsonTypeAdapter<String>(
      serializer: JsonDataSerializer<String>(), typeId: 1);
  typeAdapterRegistry.registerAdapter<String>(stringAdapter, typeId: 1);

  // Then create and register the cache item adapters
  final stringCacheItemAdapter =
      _CacheItemAdapter<String>(typeId: 1, valueAdapter: stringAdapter);
  typeAdapterRegistry.registerAdapter<String>(
    stringAdapter,
    typeId: 1,
    cacheItemAdapter: stringCacheItemAdapter,
  );

  if (adapterType == CacheAdapterType.hive) {
    Hive.registerAdapter(stringCacheItemAdapter);
  }
  // Register int adapter
  final intAdapter =
      JsonTypeAdapter<int>(serializer: JsonDataSerializer<int>(), typeId: 2);
  typeAdapterRegistry.registerAdapter<int>(intAdapter, typeId: 2);

  // Then create and register the cache item adapter
  final intCacheItemAdapter =
      _CacheItemAdapter<int>(typeId: 2, valueAdapter: intAdapter);
  typeAdapterRegistry.registerAdapter<int>(
    intAdapter,
    typeId: 2,
    cacheItemAdapter: intCacheItemAdapter,
  );

  if (adapterType == CacheAdapterType.hive) {
    Hive.registerAdapter(intCacheItemAdapter);
  }
  // Register double adapter
  final doubleAdapter = JsonTypeAdapter<double>(
      serializer: JsonDataSerializer<double>(), typeId: 3);
  typeAdapterRegistry.registerAdapter<double>(doubleAdapter, typeId: 3);

  // Then create and register the cache item adapter
  final doubleCacheItemAdapter =
      _CacheItemAdapter<double>(typeId: 3, valueAdapter: doubleAdapter);
  typeAdapterRegistry.registerAdapter<double>(
    doubleAdapter,
    typeId: 3,
    cacheItemAdapter: doubleCacheItemAdapter,
  );

  if (adapterType == CacheAdapterType.hive) {
    Hive.registerAdapter(doubleCacheItemAdapter);
  }
  // Register bool adapter
  final boolAdapter =
      JsonTypeAdapter<bool>(serializer: JsonDataSerializer<bool>(), typeId: 4);
  typeAdapterRegistry.registerAdapter<bool>(boolAdapter, typeId: 4);

  // Then create and register the cache item adapter
  final boolCacheItemAdapter =
      _CacheItemAdapter<bool>(typeId: 4, valueAdapter: boolAdapter);
  typeAdapterRegistry.registerAdapter<bool>(
    boolAdapter,
    typeId: 4,
    cacheItemAdapter: boolCacheItemAdapter,
  );

  if (adapterType == CacheAdapterType.hive) {
    Hive.registerAdapter(boolCacheItemAdapter);
  }
  // Register List<String> adapter
  final listStringAdapter = JsonTypeAdapter<List<String>>(
      serializer: JsonDataSerializer<List<String>>(), typeId: 5);
  typeAdapterRegistry.registerAdapter<List<String>>(listStringAdapter,
      typeId: 5);

  // Then create and register the cache item adapter
  final listStringCacheItemAdapter = _CacheItemAdapter<List<String>>(
      typeId: 5, valueAdapter: listStringAdapter);
  typeAdapterRegistry.registerAdapter<List<String>>(
    listStringAdapter,
    typeId: 5,
    cacheItemAdapter: listStringCacheItemAdapter,
  );

  if (adapterType == CacheAdapterType.hive) {
    Hive.registerAdapter(listStringCacheItemAdapter);
  }
  // Register Map<String, dynamic> adapter
  final mapAdapter = JsonTypeAdapter<Map<String, dynamic>>(
      serializer: JsonDataSerializer<Map<String, dynamic>>(), typeId: 6);
  typeAdapterRegistry.registerAdapter<Map<String, dynamic>>(mapAdapter,
      typeId: 6);

  // Then create and register the cache item adapter
  final mapCacheItemAdapter = _CacheItemAdapter<Map<String, dynamic>>(
      typeId: 6, valueAdapter: mapAdapter);
  typeAdapterRegistry.registerAdapter<Map<String, dynamic>>(
    mapAdapter,
    typeId: 6,
    cacheItemAdapter: mapCacheItemAdapter,
  );

  if (adapterType == CacheAdapterType.hive) {
    Hive.registerAdapter(mapCacheItemAdapter);
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
          encryptionOptions: encryptionOptions,
        );
        // Initialize the adapter by opening the Hive box
        await hiveAdapter.init();
        getIt.registerSingleton<HiveAdapter>(hiveAdapter);
        cacheAdapter = hiveAdapter;
      } else {
        cacheAdapter = getIt<HiveAdapter>();
        // Ensure the adapter is initialized
        if (cacheAdapter is HiveAdapter) {
          await (cacheAdapter).init();
        }
      }
      break;
    case CacheAdapterType.memory:
      if (!getIt.isRegistered<MemoryAdapter>()) {
        final memoryAdapter = MemoryAdapter(
          enableEncryption: enableEncryption,
          encryptionKey: encryptionKey,
          encryptionOptions: encryptionOptions,
        );
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
          encryptionOptions: encryptionOptions,
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
          encryptionOptions: encryptionOptions,
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
  BackgroundCleanup.initializeBackgroundCleanup(
    adapter: cacheAdapter,
    frequency: cleanupFrequency,
  );
}

class _CacheItemAdapter<T> extends TypeAdapter<CacheItem<T>> {
  @override
  final int typeId;
  final TypeAdapter? valueAdapter;

  _CacheItemAdapter({required this.typeId, required this.valueAdapter});

  @override
  CacheItem<T> read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    dynamic value;
    if (valueAdapter != null) {
      value = valueAdapter!.read(reader);
    } else {
      value = fields[0];
    }

    return CacheItem<T>(
      value: value as T,
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
