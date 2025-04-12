import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cache_entry.dart';
import '../../data/repositories/explorer_repository.dart';

// Events
abstract class ExplorerEvent extends Equatable {
  const ExplorerEvent();

  @override
  List<Object> get props => [];
}

class LoadEntriesEvent extends ExplorerEvent {}

class GetEntryValueEvent extends ExplorerEvent {
  final String key;

  const GetEntryValueEvent(this.key);

  @override
  List<Object> get props => [key];
}

class DeleteEntryEvent extends ExplorerEvent {
  final String key;

  const DeleteEntryEvent(this.key);

  @override
  List<Object> get props => [key];
}

class ClearAllEntriesEvent extends ExplorerEvent {}

// States
abstract class ExplorerState extends Equatable {
  const ExplorerState();

  @override
  List<Object> get props => [];
}

class ExplorerInitial extends ExplorerState {}

class ExplorerLoading extends ExplorerState {}

class EntriesLoaded extends ExplorerState {
  final List<CacheEntry> entries;
  final Map<String, dynamic> stats;

  const EntriesLoaded({
    required this.entries,
    required this.stats,
  });

  @override
  List<Object> get props => [entries, stats];
}

class EntryValueLoaded extends ExplorerState {
  final String key;
  final String? value;

  const EntryValueLoaded({
    required this.key,
    required this.value,
  });

  @override
  List<Object> get props => [key, value ?? ''];
}

class EntryDeleted extends ExplorerState {
  final String key;

  const EntryDeleted(this.key);

  @override
  List<Object> get props => [key];
}

class AllEntriesCleared extends ExplorerState {}

class ExplorerError extends ExplorerState {
  final String message;

  const ExplorerError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ExplorerBloc extends Bloc<ExplorerEvent, ExplorerState> {
  final ExplorerRepository _explorerRepository;

  ExplorerBloc({required ExplorerRepository explorerRepository})
      : _explorerRepository = explorerRepository,
        super(ExplorerInitial()) {
    on<LoadEntriesEvent>(_onLoadEntries);
    on<GetEntryValueEvent>(_onGetEntryValue);
    on<DeleteEntryEvent>(_onDeleteEntry);
    on<ClearAllEntriesEvent>(_onClearAllEntries);
  }

  Future<void> _onLoadEntries(
    LoadEntriesEvent event,
    Emitter<ExplorerState> emit,
  ) async {
    emit(ExplorerLoading());
    try {
      final entries = await _explorerRepository.getAllEntries();
      final stats = await _explorerRepository.getCacheStats();

      emit(EntriesLoaded(
        entries: entries,
        stats: stats,
      ));
    } catch (e) {
      emit(ExplorerError('Failed to load entries: ${e.toString()}'));
    }
  }

  Future<void> _onGetEntryValue(
    GetEntryValueEvent event,
    Emitter<ExplorerState> emit,
  ) async {
    emit(ExplorerLoading());
    try {
      final value = await _explorerRepository.getEntryValue(event.key);

      emit(EntryValueLoaded(
        key: event.key,
        value: value,
      ));
    } catch (e) {
      emit(ExplorerError('Failed to get entry value: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteEntry(
    DeleteEntryEvent event,
    Emitter<ExplorerState> emit,
  ) async {
    emit(ExplorerLoading());
    try {
      final success = await _explorerRepository.deleteEntry(event.key);

      if (success) {
        emit(EntryDeleted(event.key));
        add(LoadEntriesEvent());
      } else {
        emit(const ExplorerError('Failed to delete entry'));
      }
    } catch (e) {
      emit(ExplorerError('Failed to delete entry: ${e.toString()}'));
    }
  }

  Future<void> _onClearAllEntries(
    ClearAllEntriesEvent event,
    Emitter<ExplorerState> emit,
  ) async {
    emit(ExplorerLoading());
    try {
      final success = await _explorerRepository.clearAll();

      if (success) {
        emit(AllEntriesCleared());
        add(LoadEntriesEvent());
      } else {
        emit(const ExplorerError('Failed to clear all entries'));
      }
    } catch (e) {
      emit(ExplorerError('Failed to clear all entries: ${e.toString()}'));
    }
  }
}
