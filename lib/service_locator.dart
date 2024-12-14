import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/adapters/hive/hive_adapter.dart';
import 'package:data_cache_x/adapters/memory_adapter.dart';
import 'package:data_cache_x/core/data_cache_x.dart';
import 'package:data_cache_x/core/exception.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:data_cache_x/serializers/data_serializer.dart';
import 'package:data_cache_x/serializers/json_data_serializer.dart';
import 'package:data_cache_x/utils/background_cleanup.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum CacheAdapterType {
  hive,
  memory,
}

final getIt = GetIt.instance;

class TypeAdapterRegistry {
  static final TypeAdapterRegistry _instance = TypeAdapterRegistry._internal();

  factory TypeAdapterRegistry() {
    return _instance;
  }

  TypeAdapterRegistry._internal();

  final Map<Type, int> _typeIds = {};
  final Map<int, TypeAdapter> _adapters = {};
  final Set<int> _registeredTypeIds = {};
  final Map<Type, DataSerializer> _serializers = {};

  void registerAdapter<T>(TypeAdapter<CacheItem<T>> adapter, {int? typeId}) {
    final actualTypeId = typeId ?? _typeIds.length + 100;
    _typeIds[T] = actualTypeId;
    _adapters[actualTypeId] = adapter;
    if (!_registeredTypeIds.contains(actualTypeId)) {
      Hive.registerAdapter(adapter);
      _registeredTypeIds.add(actualTypeId);
    }
  }

  void registerSerializer<T>(DataSerializer<T> serializer) {
    _serializers[T] = serializer;
  }

  TypeAdapter<CacheItem<T>> getAdapter<T>() {
    final typeId = _typeIds[T];
    if (typeId == null) {
      throw AdapterNotFoundException('No adapter registered for type $T');
    }
    final adapter = _adapters[typeId];
    if (adapter == null) {
      throw AdapterNotFoundException(
          'No adapter registered for type ID $typeId');
    }
    return adapter as TypeAdapter<CacheItem<T>>;
  }

  DataSerializer<T> getSerializer<T>() {
    final serializer = _serializers[T];
    if (serializer == null) {
      throw SerializerNotFoundException('No serializer registered for type $T');
    }
    return serializer as DataSerializer<T>;
  }
}

Future<void> setupDataCacheX({
  String? boxName,
  Duration? cleanupFrequency,
  CacheAdapterType adapterType = CacheAdapterType.hive,
  bool enableEncryption = false,
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
  customAdapters?.forEach((type, adapter) {
    typeAdapterRegistry.registerAdapter(adapter);
  });

  typeAdapterRegistry.registerAdapter(
    _CacheItemAdapter<dynamic>(typeId: 0),
  );

  // Register default serializers
  typeAdapterRegistry.registerSerializer<String>(JsonDataSerializer<String>());
  typeAdapterRegistry.registerSerializer<int>(JsonDataSerializer<int>());
  typeAdapterRegistry.registerSerializer<double>(JsonDataSerializer<double>());
  typeAdapterRegistry.registerSerializer<bool>(JsonDataSerializer<bool>());
  typeAdapterRegistry
      .registerSerializer<List<String>>(JsonDataSerializer<List<String>>());
  typeAdapterRegistry.registerSerializer<Map<String, dynamic>>(
      JsonDataSerializer<Map<String, dynamic>>());

  // Register custom serializers
  customSerializers?.forEach((type, serializer) {
    typeAdapterRegistry.registerSerializer(serializer);
  });

  // Register CacheAdapter
  CacheAdapter cacheAdapter;
  if (adapterType == CacheAdapterType.hive) {
    final hiveAdapter = HiveAdapter(
      typeAdapterRegistry,
      boxName: boxName,
      enableEncryption: enableEncryption,
    );
    getIt.registerSingleton<HiveAdapter>(hiveAdapter);
    cacheAdapter = hiveAdapter;
  } else {
    final memoryAdapter = MemoryAdapter(enableEncryption: enableEncryption);
    getIt.registerSingleton<MemoryAdapter>(memoryAdapter);
    cacheAdapter = memoryAdapter;
  }

  // Register DataCacheX
  getIt.registerSingleton<DataCacheX>(DataCacheX(cacheAdapter));

  // Initialize background cleanup
  initializeBackgroundCleanup(
      adapter: cacheAdapter, frequency: cleanupFrequency);
}

class _CacheItemAdapter<T> extends TypeAdapter<CacheItem<T>> {
  @override
  final int typeId;

  _CacheItemAdapter({required this.typeId});

  @override
  CacheItem<T> read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheItem<T>(
      value: fields[0] as T,
      expiry: fields[1] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CacheItem<T> obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.expiry);
  }
}
