import 'package:example/models/todo_item.dart';
import 'package:example/todo_app/bloc/todo_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          String? lastUpdated;
          if (state is TodosLoaded) {
            lastUpdated = state.lastUpdated != null
                ? DateFormat.yMd().add_Hms().format(state.lastUpdated!)
                : null;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (lastUpdated != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Last updated: $lastUpdated'),
                ),
              Expanded(
                child: _buildTodoList(state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              context.read<TodoBloc>().add(RefreshTodosEvent());
            },
            tooltip: 'Refresh',
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _showAddTodoDialog(context);
            },
            tooltip: 'Add Todo',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(TodoState state) {
    if (state is TodosLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is TodosLoaded) {
      if (state.todos.isEmpty) {
        return const Center(child: Text('No todos yet'));
      }
      return ListView.builder(
        itemCount: state.todos.length,
        itemBuilder: (context, index) {
          final todo = state.todos[index];
          return ListTile(
            title: Text(todo.title),
            subtitle: Text(todo.description),
            trailing: Checkbox(
              value: todo.completed,
              onChanged: (value) {
                context.read<TodoBloc>().add(
                      UpdateTodoEvent(
                        todo.copyWith(completed: value),
                      ),
                    );
              },
            ),
            onLongPress: () {
              _showOptionsBottomSheet(context, todo);
            },
          );
        },
      );
    } else if (state is TodosError) {
      return Center(child: Text(state.message));
    } else {
      return const Center(child: Text('No todos yet'));
    }
  }

  void _showAddTodoDialog(BuildContext parentContext) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newTodo = TodoItem(
                  id: '',
                  title: titleController.text,
                  description: descriptionController.text,
                );
                parentContext.read<TodoBloc>().add(AddTodoEvent(newTodo));
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showOptionsBottomSheet(BuildContext parentContext, TodoItem todo) {
    // Capture the bloc reference before showing bottom sheet
    final todoBloc = parentContext.read<TodoBloc>();

    showModalBottomSheet(
      context: parentContext,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(parentContext, todo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: parentContext,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Delete Todo'),
                      content: const Text(
                          'Are you sure you want to delete this todo?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            todoBloc.add(DeleteTodoEvent(todo.id));
                            Navigator.pop(dialogContext);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext parentContext, TodoItem todo) {
    final titleController = TextEditingController(text: todo.title);
    final descriptionController = TextEditingController(text: todo.description);
    // Capture the bloc reference before showing dialog
    final todoBloc = parentContext.read<TodoBloc>();

    showDialog(
      context: parentContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedTodo = todo.copyWith(
                  title: titleController.text,
                  description: descriptionController.text,
                );
                // Use captured bloc reference instead of context.read
                todoBloc.add(UpdateTodoEvent(updatedTodo));
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
