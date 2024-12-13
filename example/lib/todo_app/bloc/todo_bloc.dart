import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:example/models/todo_item.dart';
import 'package:example/todo_app/data/todo_repository.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _todoRepository;

  TodoBloc(this._todoRepository) : super(TodoInitial()) {
    on<LoadTodosEvent>((event, emit) async {
      emit(TodosLoading());
      try {
        final todos = await _todoRepository.getTodos();
        emit(TodosLoaded(todos));
      } catch (e) {
        emit(TodosError(e.toString()));
      }
    });

    on<AddTodoEvent>((event, emit) async {
      try {
        await _todoRepository.addTodo(event.todo);
        final todos = await _todoRepository.getTodos();
        emit(TodosLoaded(todos));
      } catch (e) {
        emit(TodosError(e.toString()));
      }
    });

    on<UpdateTodoEvent>((event, emit) async {
      try {
        await _todoRepository.updateTodo(event.todo);
        final todos = await _todoRepository.getTodos();
        emit(TodosLoaded(todos));
      } catch (e) {
        emit(TodosError(e.toString()));
      }
    });

    on<DeleteTodoEvent>((event, emit) async {
      try {
        await _todoRepository.deleteTodo(event.id);
        final todos = await _todoRepository.getTodos();
        emit(TodosLoaded(todos));
      } catch (e) {
        emit(TodosError(e.toString()));
      }
    });

    on<RefreshTodosEvent>((event, emit) async {
      try {
        final todos = await _todoRepository.getTodos();
        emit(TodosLoaded(todos, lastUpdated: DateTime.now()));
      } catch (e) {
        emit(TodosError(e.toString()));
      }
    });
  }
}
