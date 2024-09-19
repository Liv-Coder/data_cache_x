// Mocks generated by Mockito 5.4.4 from annotations
// in data_cache_x/test/local_data_source_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:data_cache_x/data/data%20source/local/local_data_source.dart'
    as _i2;
import 'package:data_cache_x/data/repositories/cache_repository.dart' as _i3;
import 'package:data_cache_x/data_cache_x.dart' as _i5;
import 'package:data_cache_x/domain/usecases/clear_all_cache_data_usecase.dart'
    as _i7;
import 'package:data_cache_x/domain/usecases/clear_cache_data_usecase.dart'
    as _i6;
import 'package:data_cache_x/domain/usecases/print_cache_contents_usecase.dart'
    as _i8;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeLocalDataSource_0 extends _i1.SmartFake
    implements _i2.LocalDataSource {
  _FakeLocalDataSource_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCacheRepository_1 extends _i1.SmartFake
    implements _i3.CacheRepository {
  _FakeCacheRepository_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [CacheRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockCacheRepository extends _i1.Mock implements _i3.CacheRepository {
  MockCacheRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.LocalDataSource get localDataSource => (super.noSuchMethod(
        Invocation.getter(#localDataSource),
        returnValue: _FakeLocalDataSource_0(
          this,
          Invocation.getter(#localDataSource),
        ),
      ) as _i2.LocalDataSource);

  @override
  _i4.Future<void> cacheData(
    String? key,
    String? data,
    Duration? expirationDuration,
    bool? isCompressed,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #cacheData,
          [
            key,
            data,
            expirationDuration,
            isCompressed,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<String?> getCachedData(String? key) => (super.noSuchMethod(
        Invocation.method(
          #getCachedData,
          [key],
        ),
        returnValue: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);

  @override
  _i4.Future<void> clearCache(String? key) => (super.noSuchMethod(
        Invocation.method(
          #clearCache,
          [key],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> clearAllCache() => (super.noSuchMethod(
        Invocation.method(
          #clearAllCache,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> printCacheContents() => (super.noSuchMethod(
        Invocation.method(
          #printCacheContents,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}

/// A class which mocks [CacheDataUseCase].
///
/// See the documentation for Mockito's code generation for more information.
class MockCacheDataUseCase extends _i1.Mock implements _i5.CacheDataUseCase {
  MockCacheDataUseCase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.CacheRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeCacheRepository_1(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i3.CacheRepository);

  @override
  _i4.Future<void> call(
    String? key,
    String? data,
    Duration? expirationDuration,
    bool? isCompressed,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #call,
          [
            key,
            data,
            expirationDuration,
            isCompressed,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}

/// A class which mocks [GetCachedDataUseCase].
///
/// See the documentation for Mockito's code generation for more information.
class MockGetCachedDataUseCase extends _i1.Mock
    implements _i5.GetCachedDataUseCase {
  MockGetCachedDataUseCase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.CacheRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeCacheRepository_1(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i3.CacheRepository);

  @override
  _i4.Future<String?> call(String? key) => (super.noSuchMethod(
        Invocation.method(
          #call,
          [key],
        ),
        returnValue: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);
}

/// A class which mocks [ClearCacheDataUsecase].
///
/// See the documentation for Mockito's code generation for more information.
class MockClearCacheDataUsecase extends _i1.Mock
    implements _i6.ClearCacheDataUsecase {
  MockClearCacheDataUsecase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.CacheRepository get cacheRepository => (super.noSuchMethod(
        Invocation.getter(#cacheRepository),
        returnValue: _FakeCacheRepository_1(
          this,
          Invocation.getter(#cacheRepository),
        ),
      ) as _i3.CacheRepository);

  @override
  _i4.Future<void> call(String? key) => (super.noSuchMethod(
        Invocation.method(
          #call,
          [key],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}

/// A class which mocks [ClearAllCacheDataUsecase].
///
/// See the documentation for Mockito's code generation for more information.
class MockClearAllCacheDataUsecase extends _i1.Mock
    implements _i7.ClearAllCacheDataUsecase {
  MockClearAllCacheDataUsecase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.CacheRepository get cacheRepository => (super.noSuchMethod(
        Invocation.getter(#cacheRepository),
        returnValue: _FakeCacheRepository_1(
          this,
          Invocation.getter(#cacheRepository),
        ),
      ) as _i3.CacheRepository);

  @override
  _i4.Future<void> call() => (super.noSuchMethod(
        Invocation.method(
          #call,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}

/// A class which mocks [PrintCacheContentsUsecase].
///
/// See the documentation for Mockito's code generation for more information.
class MockPrintCacheContentsUsecase extends _i1.Mock
    implements _i8.PrintCacheContentsUsecase {
  MockPrintCacheContentsUsecase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.CacheRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeCacheRepository_1(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i3.CacheRepository);

  @override
  _i4.Future<void> call() => (super.noSuchMethod(
        Invocation.method(
          #call,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}
