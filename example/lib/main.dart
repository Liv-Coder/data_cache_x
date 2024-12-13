import 'package:example/news_app/bloc/news_bloc.dart';
import 'package:example/news_app/screens/news_screen.dart';
import 'package:example/service_locator.dart';
import 'package:example/todo_app/bloc/todo_bloc.dart';
import 'package:example/todo_app/screens/todo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataCacheX Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DataCacheX Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider<NewsBloc>(
                      create: (context) => getIt<NewsBloc>(),
                      child: const NewsScreen(),
                    ),
                  ),
                );
              },
              child: const Text('News App'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider<TodoBloc>(
                      create: (context) =>
                          getIt<TodoBloc>()..add(LoadTodosEvent()),
                      child: const TodoScreen(),
                    ),
                  ),
                );
              },
              child: const Text('Todo App'),
            ),
          ],
        ),
      ),
    );
  }
}
