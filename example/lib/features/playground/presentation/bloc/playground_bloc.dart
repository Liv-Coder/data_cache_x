import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/adapter_benchmark.dart';
import '../../data/models/benchmark_result.dart';
import '../../data/repositories/playground_repository.dart';

// Events
abstract class PlaygroundEvent extends Equatable {
  const PlaygroundEvent();

  @override
  List<Object> get props => [];
}

class LoadAdaptersEvent extends PlaygroundEvent {}

class RunBenchmarkEvent extends PlaygroundEvent {
  final String adapter;
  final AdapterBenchmark benchmark;

  const RunBenchmarkEvent({
    required this.adapter,
    required this.benchmark,
  });

  @override
  List<Object> get props => [adapter, benchmark];
}

class RunComparisonBenchmarkEvent extends PlaygroundEvent {
  final AdapterBenchmark benchmark;

  const RunComparisonBenchmarkEvent({
    required this.benchmark,
  });

  @override
  List<Object> get props => [benchmark];
}

// States
abstract class PlaygroundState extends Equatable {
  const PlaygroundState();
  
  @override
  List<Object> get props => [];
}

class PlaygroundInitial extends PlaygroundState {}

class PlaygroundLoading extends PlaygroundState {}

class AdaptersLoaded extends PlaygroundState {
  final List<String> adapters;

  const AdaptersLoaded({
    required this.adapters,
  });
  
  @override
  List<Object> get props => [adapters];
}

class BenchmarkRunning extends PlaygroundState {
  final String adapter;

  const BenchmarkRunning({
    required this.adapter,
  });
  
  @override
  List<Object> get props => [adapter];
}

class BenchmarkCompleted extends PlaygroundState {
  final BenchmarkResult result;

  const BenchmarkCompleted({
    required this.result,
  });
  
  @override
  List<Object> get props => [result];
}

class ComparisonBenchmarkCompleted extends PlaygroundState {
  final List<BenchmarkResult> results;

  const ComparisonBenchmarkCompleted({
    required this.results,
  });
  
  @override
  List<Object> get props => [results];
}

class PlaygroundError extends PlaygroundState {
  final String message;

  const PlaygroundError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Bloc
class PlaygroundBloc extends Bloc<PlaygroundEvent, PlaygroundState> {
  final PlaygroundRepository _playgroundRepository;

  PlaygroundBloc({required PlaygroundRepository playgroundRepository})
      : _playgroundRepository = playgroundRepository,
        super(PlaygroundInitial()) {
    on<LoadAdaptersEvent>(_onLoadAdapters);
    on<RunBenchmarkEvent>(_onRunBenchmark);
    on<RunComparisonBenchmarkEvent>(_onRunComparisonBenchmark);
  }

  Future<void> _onLoadAdapters(
    LoadAdaptersEvent event,
    Emitter<PlaygroundState> emit,
  ) async {
    emit(PlaygroundLoading());
    try {
      final adapters = _playgroundRepository.getAvailableAdapters();
      
      emit(AdaptersLoaded(
        adapters: adapters,
      ));
    } catch (e) {
      emit(PlaygroundError('Failed to load adapters: ${e.toString()}'));
    }
  }

  Future<void> _onRunBenchmark(
    RunBenchmarkEvent event,
    Emitter<PlaygroundState> emit,
  ) async {
    emit(BenchmarkRunning(adapter: event.adapter));
    try {
      final result = await _playgroundRepository.runBenchmark(
        event.adapter,
        event.benchmark,
      );
      
      emit(BenchmarkCompleted(
        result: result,
      ));
    } catch (e) {
      emit(PlaygroundError('Failed to run benchmark: ${e.toString()}'));
    }
  }

  Future<void> _onRunComparisonBenchmark(
    RunComparisonBenchmarkEvent event,
    Emitter<PlaygroundState> emit,
  ) async {
    emit(PlaygroundLoading());
    try {
      final results = await _playgroundRepository.runComparisonBenchmark(
        event.benchmark,
      );
      
      emit(ComparisonBenchmarkCompleted(
        results: results,
      ));
    } catch (e) {
      emit(PlaygroundError('Failed to run comparison benchmark: ${e.toString()}'));
    }
  }
}
