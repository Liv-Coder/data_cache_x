import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/article.dart';
import '../../data/repositories/news_repository.dart';

// Events
abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object> get props => [];
}

class FetchHeadlinesEvent extends NewsEvent {}

class FetchTechNewsEvent extends NewsEvent {}

class FetchBusinessNewsEvent extends NewsEvent {}

class FetchTagsEvent extends NewsEvent {}

class FilterByTagEvent extends NewsEvent {
  final String tag;

  const FilterByTagEvent(this.tag);

  @override
  List<Object> get props => [tag];
}

class ClearTagFilterEvent extends NewsEvent {}

class ClearCacheEvent extends NewsEvent {}

// States
abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<Article> articles;
  final String category;
  final String cachePolicy;
  final Set<String> availableTags;
  final String? activeTagFilter;

  const NewsLoaded({
    required this.articles,
    required this.category,
    required this.cachePolicy,
    this.availableTags = const {},
    this.activeTagFilter,
  });

  @override
  List<Object> get props => [
        articles,
        category,
        cachePolicy,
        availableTags,
        if (activeTagFilter != null) activeTagFilter!,
      ];

  NewsLoaded copyWith({
    List<Article>? articles,
    String? category,
    String? cachePolicy,
    Set<String>? availableTags,
    String? activeTagFilter,
    bool clearTagFilter = false,
  }) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      category: category ?? this.category,
      cachePolicy: cachePolicy ?? this.cachePolicy,
      availableTags: availableTags ?? this.availableTags,
      activeTagFilter:
          clearTagFilter ? null : (activeTagFilter ?? this.activeTagFilter),
    );
  }
}

class TagsLoaded extends NewsState {
  final Set<String> tags;

  const TagsLoaded({required this.tags});

  @override
  List<Object> get props => [tags];
}

class NewsError extends NewsState {
  final String message;

  const NewsError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository _newsRepository;

  NewsBloc({required NewsRepository newsRepository})
      : _newsRepository = newsRepository,
        super(NewsInitial()) {
    on<FetchHeadlinesEvent>(_onFetchHeadlines);
    on<FetchTechNewsEvent>(_onFetchTechNews);
    on<FetchBusinessNewsEvent>(_onFetchBusinessNews);
    on<FetchTagsEvent>(_onFetchTags);
    on<FilterByTagEvent>(_onFilterByTag);
    on<ClearTagFilterEvent>(_onClearTagFilter);
    on<ClearCacheEvent>(_onClearCache);
  }

  Future<void> _onFetchHeadlines(
    FetchHeadlinesEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    try {
      final articles = await _newsRepository.getHeadlines();
      final tags = await _newsRepository.getAllTags();
      emit(NewsLoaded(
        articles: articles,
        category: 'Headlines',
        cachePolicy: 'Standard (15 min expiry, stale-while-revalidate)',
        availableTags: tags,
      ));
    } catch (e) {
      emit(NewsError('Failed to load headlines: ${e.toString()}'));
    }
  }

  Future<void> _onFetchTags(
    FetchTagsEvent event,
    Emitter<NewsState> emit,
  ) async {
    try {
      final tags = await _newsRepository.getAllTags();
      emit(TagsLoaded(tags: tags));
    } catch (e) {
      emit(NewsError('Failed to load tags: ${e.toString()}'));
    }
  }

  Future<void> _onFilterByTag(
    FilterByTagEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    try {
      final articles = await _newsRepository.getArticlesByTag(event.tag);
      final tags = await _newsRepository.getAllTags();

      emit(NewsLoaded(
        articles: articles,
        category: 'Tag: #${event.tag}',
        cachePolicy: 'Mixed (from various sources)',
        availableTags: tags,
        activeTagFilter: event.tag,
      ));
    } catch (e) {
      emit(NewsError('Failed to filter by tag: ${e.toString()}'));
    }
  }

  Future<void> _onClearTagFilter(
    ClearTagFilterEvent event,
    Emitter<NewsState> emit,
  ) async {
    add(FetchHeadlinesEvent());
  }

  Future<void> _onFetchTechNews(
    FetchTechNewsEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    try {
      final articles = await _newsRepository.getTechNews();
      final tags = await _newsRepository.getAllTags();
      emit(NewsLoaded(
        articles: articles,
        category: 'Technology',
        cachePolicy: 'Long-term (2 hour expiry, sliding window)',
        availableTags: tags,
      ));
    } catch (e) {
      emit(NewsError('Failed to load tech news: ${e.toString()}'));
    }
  }

  Future<void> _onFetchBusinessNews(
    FetchBusinessNewsEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    try {
      final articles = await _newsRepository.getBusinessNews();
      final tags = await _newsRepository.getAllTags();
      emit(NewsLoaded(
        articles: articles,
        category: 'Business',
        cachePolicy: 'Critical (30 min expiry, compression)',
        availableTags: tags,
      ));
    } catch (e) {
      emit(NewsError('Failed to load business news: ${e.toString()}'));
    }
  }

  Future<void> _onClearCache(
    ClearCacheEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    try {
      await _newsRepository.clearCache();
      emit(NewsInitial());
    } catch (e) {
      emit(NewsError('Failed to clear cache: ${e.toString()}'));
    }
  }
}
