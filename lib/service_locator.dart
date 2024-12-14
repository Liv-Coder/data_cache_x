import 'package:data_cache_x/adapters/hive/hive_adapter.dart';
import 'package:data_cache_x/core/data_cache_x.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:data_cache_x/utils/background_cleanup.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  void registerAdapter<T>(TypeAdapter<CacheItem<T>> adapter,
      {required int typeId}) {
    _typeIds[T] = typeId;
    _adapters[typeId] = adapter;
    if (!_registeredTypeIds.contains(typeId)) {
      Hive.registerAdapter(adapter);
      _registeredTypeIds.add(typeId);
    }
  }

  TypeAdapter<CacheItem<T>> getAdapter<T>() {
    final typeId = _typeIds[T];
    if (typeId == null) {
      throw Exception('No adapter registered for type $T');
    }
    final adapter = _adapters[typeId];
    if (adapter == null) {
      throw Exception('No adapter registered for type ID $typeId');
    }
    return adapter as TypeAdapter<CacheItem<T>>;
  }
}

Future<void> setupDataCacheX(
    {String? boxName, Duration? cleanupFrequency}) async {
  // Register TypeAdapterRegistry
  getIt.registerSingleton<TypeAdapterRegistry>(TypeAdapterRegistry());

  // Initialize Hive
  await Hive.initFlutter();

  // Register default adapters
  final typeAdapterRegistry = getIt<TypeAdapterRegistry>();
  typeAdapterRegistry.registerAdapter(
    _CacheItemAdapter<String>(typeId: 1),
    typeId: 1,
  );
  typeAdapterRegistry.registerAdapter(
    _CacheItemAdapter<int>(typeId: 2),
    typeId: 2,
  );
  typeAdapterRegistry.registerAdapter(
    _CacheItemAdapter<double>(typeId: 3),
    typeId: 3,
  );
  typeAdapterRegistry.registerAdapter(
    _CacheItemAdapter<bool>(typeId: 4),
    typeId: 4,
  );
  typeAdapterRegistry.registerAdapter(
    _CacheItemAdapter<List<String>>(typeId: 5),
    typeId: 5,
  );
  typeAdapterRegistry.registerAdapter(
    _CacheItemAdapter<Map<String, dynamic>>(typeId: 6),
    typeId: 6,
  );

  // Register HiveAdapter
  final hiveAdapter = HiveAdapter(typeAdapterRegistry, boxName: boxName);
  getIt.registerSingleton<HiveAdapter>(hiveAdapter);

  // Register DataCacheX
  getIt.registerSingleton<DataCacheX>(DataCacheX(hiveAdapter));

  // Initialize background cleanup
  initializeBackgroundCleanup(frequency: cleanupFrequency);
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
