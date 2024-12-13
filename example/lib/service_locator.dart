import 'package:data_cache_x/service_locator.dart'
    as data_cache_x_service_locator;
import 'package:example/news_app/data/news_provider.dart';
import 'package:example/news_app/data/news_repository.dart';
import 'package:example/news_app/bloc/news_bloc.dart';
import 'package:example/todo_app/data/todo_provider.dart';
import 'package:example/todo_app/data/todo_repository.dart';
import 'package:example/todo_app/bloc/todo_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  // News App
  getIt.registerFactory(() => NewsProvider());
  getIt.registerFactory(() => NewsRepository(getIt(), getIt()));
  getIt.registerFactory(() => NewsBloc(getIt()));

  // Todo App
  getIt.registerFactory(() => TodoProvider(getIt()));
  getIt.registerFactory(() => TodoRepository(getIt()));
  getIt.registerFactory(() => TodoBloc(getIt()));

  // DataCacheX setup
  await data_cache_x_service_locator.setupDataCacheX();
}
