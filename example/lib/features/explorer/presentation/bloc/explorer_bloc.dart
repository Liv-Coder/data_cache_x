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

class LoadTagsEvent extends ExplorerEvent {}

class FilterByTagEvent extends ExplorerEvent {
  final String tag;

  const FilterByTagEvent(this.tag);

  @override
  List<Object> get props => [tag];
}

class ClearTagFilterEvent extends ExplorerEvent {}

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

class DeleteByTagEvent extends ExplorerEvent {
  final String tag;

  const DeleteByTagEvent(this.tag);

  @override
  List<Object> get props => [tag];
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
  final Set<String> availableTags;
  final String? activeTagFilter;

  const EntriesLoaded({
    required this.entries,
    required this.stats,
    this.availableTags = const {},
    this.activeTagFilter,
  });

  @override
  List<Object> get props => [
        entries,
        stats,
        availableTags,
        if (activeTagFilter != null) activeTagFilter!,
      ];

  EntriesLoaded copyWith({
    List<CacheEntry>? entries,
    Map<String, dynamic>? stats,
    Set<String>? availableTags,
    String? activeTagFilter,
    bool clearTagFilter = false,
  }) {
    return EntriesLoaded(
      entries: entries ?? this.entries,
      stats: stats ?? this.stats,
      availableTags: availableTags ?? this.availableTags,
      activeTagFilter:
          clearTagFilter ? null : (activeTagFilter ?? this.activeTagFilter),
    );
  }
}

class TagsLoaded extends ExplorerState {
  final Set<String> tags;

  const TagsLoaded({required this.tags});

  @override
  List<Object> get props => [tags];
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

class EntriesByTagDeleted extends ExplorerState {
  final String tag;

  const EntriesByTagDeleted(this.tag);

  @override
  List<Object> get props => [tag];
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
    on<LoadTagsEvent>(_onLoadTags);
    on<FilterByTagEvent>(_onFilterByTag);
    on<ClearTagFilterEvent>(_onClearTagFilter);
    on<GetEntryValueEvent>(_onGetEntryValue);
    on<DeleteEntryEvent>(_onDeleteEntry);
    on<DeleteByTagEvent>(_onDeleteByTag);
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
      final tags = await _explorerRepository.getAllTags();

      emit(EntriesLoaded(
        entries: entries,
        stats: stats,
        availableTags: tags,
      ));
    } catch (e) {
      emit(ExplorerError('Failed to load entries: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTags(
    LoadTagsEvent event,
    Emitter<ExplorerState> emit,
  ) async {
    try {
      final tags = await _explorerRepository.getAllTags();
      emit(TagsLoaded(tags: tags));
    } catch (e) {
      emit(ExplorerError('Failed to load tags: ${e.toString()}'));
    }
  }

  Future<void> _onFilterByTag(
    FilterByTagEvent event,
    Emitter<ExplorerState> emit,
  ) async {
    emit(ExplorerLoading());
    try {
      final entries = await _explorerRepository.getEntriesByTag(event.tag);
      final stats = await _explorerRepository.getCacheStats();
      final tags = await _explorerRepository.getAllTags();

      emit(EntriesLoaded(
        entries: entries,
        stats: stats,
        availableTags: tags,
        activeTagFilter: event.tag,
      ));
    } catch (e) {
      emit(ExplorerError('Failed to filter by tag: ${e.toString()}'));
    }
  }

  Future<void> _onClearTagFilter(
    ClearTagFilterEvent event,
    Emitter<ExplorerState> emit,
  ) async {
    emit(ExplorerLoading());
    try {
      final entries = await _explorerRepository.getAllEntries();
      final stats = await _explorerRepository.getCacheStats();
      final tags = await _explorerRepository.getAllTags();

      emit(EntriesLoaded(
        entries: entries,
        stats: stats,
        availableTags: tags,
      ));
    } catch (e) {
      emit(ExplorerError('Failed to clear tag filter: ${e.toString()}'));
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

  Future<void> _onDeleteByTag(
    DeleteByTagEvent event,
    Emitter<ExplorerState> emit,
  ) async {
    emit(ExplorerLoading());
    try {
      final success = await _explorerRepository.deleteByTag(event.tag);

      if (success) {
        emit(EntriesByTagDeleted(event.tag));
        add(LoadEntriesEvent());
      } else {
        emit(const ExplorerError('Failed to delete entries by tag'));
      }
    } catch (e) {
      emit(ExplorerError('Failed to delete entries by tag: ${e.toString()}'));
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
