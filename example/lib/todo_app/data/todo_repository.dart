import 'package:example/models/todo_item.dart';
import 'package:example/todo_app/data/todo_provider.dart';

class TodoRepository {
  final TodoProvider _todoProvider;

  TodoRepository(this._todoProvider);

  Future<List<TodoItem>> getTodos() async {
    return await _todoProvider.getTodos();
  }

  Future<void> addTodo(TodoItem todo) async {
    await _todoProvider.addTodo(todo);
  }

  Future<void> updateTodo(TodoItem todo) async {
    await _todoProvider.updateTodo(todo);
  }

  Future<void> deleteTodo(String id) async {
    await _todoProvider.deleteTodo(id);
  }
}
