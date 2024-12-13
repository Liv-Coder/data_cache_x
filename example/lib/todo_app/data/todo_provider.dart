import 'package:data_cache_x/core/data_cache_x.dart';
import 'package:example/models/todo_item.dart';
import 'package:uuid/uuid.dart';

class TodoProvider {
  final DataCacheX _dataCache;
  final String _cacheKey = 'todos';

  TodoProvider(this._dataCache);

  Future<List<TodoItem>> getTodos() async {
    final cachedData = await _dataCache.get(_cacheKey);

    if (cachedData != null) {
      return (cachedData as List)
          .map((e) => TodoItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return [];
  }

  Future<void> addTodo(TodoItem todo) async {
    final todos = await getTodos();
    final newTodo = todo.copyWith(id: const Uuid().v4());
    todos.add(newTodo);
    await _dataCache.put(_cacheKey, todos.map((e) => e.toJson()).toList());
  }

  Future<void> updateTodo(TodoItem updatedTodo) async {
    final todos = await getTodos();
    final index = todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      todos[index] = updatedTodo;
      await _dataCache.put(_cacheKey, todos.map((e) => e.toJson()).toList());
    }
  }

  Future<void> deleteTodo(String id) async {
    final todos = await getTodos();
    todos.removeWhere((todo) => todo.id == id);
    await _dataCache.put(_cacheKey, todos.map((e) => e.toJson()).toList());
  }
}
