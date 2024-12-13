part of 'todo_bloc.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object> get props => [];
}

class TodoInitial extends TodoState {}

class TodosLoading extends TodoState {}

class TodosLoaded extends TodoState {
  final List<TodoItem> todos;
  final DateTime? lastUpdated;

  const TodosLoaded(this.todos, {this.lastUpdated});

  @override
  List<Object> get props => [todos, lastUpdated ?? ''];
}

class TodosError extends TodoState {
  final String message;

  const TodosError(this.message);

  @override
  List<Object> get props => [message];
}
