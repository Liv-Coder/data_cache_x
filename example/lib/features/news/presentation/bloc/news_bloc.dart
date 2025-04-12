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

  const NewsLoaded({
    required this.articles,
    required this.category,
    required this.cachePolicy,
  });
  
  @override
  List<Object> get props => [articles, category, cachePolicy];
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
    on<ClearCacheEvent>(_onClearCache);
  }

  Future<void> _onFetchHeadlines(
    FetchHeadlinesEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    try {
      final articles = await _newsRepository.getHeadlines();
      emit(NewsLoaded(
        articles: articles,
        category: 'Headlines',
        cachePolicy: 'Standard (15 min expiry, stale-while-revalidate)',
      ));
    } catch (e) {
      emit(NewsError('Failed to load headlines: ${e.toString()}'));
    }
  }

  Future<void> _onFetchTechNews(
    FetchTechNewsEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    try {
      final articles = await _newsRepository.getTechNews();
      emit(NewsLoaded(
        articles: articles,
        category: 'Technology',
        cachePolicy: 'Long-term (2 hour expiry, sliding window)',
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
      emit(NewsLoaded(
        articles: articles,
        category: 'Business',
        cachePolicy: 'Critical (30 min expiry, compression)',
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
