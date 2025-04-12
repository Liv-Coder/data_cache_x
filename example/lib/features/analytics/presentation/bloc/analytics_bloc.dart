import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/analytics_repository.dart';

// Events
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object> get props => [];
}

class LoadAnalyticsEvent extends AnalyticsEvent {}

class GenerateSampleDataEvent extends AnalyticsEvent {}

class ResetMetricsEvent extends AnalyticsEvent {}

// States
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  
  @override
  List<Object> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final Map<String, dynamic> summary;
  final double hitRate;
  final int totalSize;
  final List<Map<String, dynamic>> mostFrequentlyAccessedKeys;
  final List<Map<String, dynamic>> mostRecentlyAccessedKeys;
  final List<Map<String, dynamic>> largestItems;

  const AnalyticsLoaded({
    required this.summary,
    required this.hitRate,
    required this.totalSize,
    required this.mostFrequentlyAccessedKeys,
    required this.mostRecentlyAccessedKeys,
    required this.largestItems,
  });
  
  @override
  List<Object> get props => [
    summary, 
    hitRate, 
    totalSize, 
    mostFrequentlyAccessedKeys, 
    mostRecentlyAccessedKeys, 
    largestItems
  ];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Bloc
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _analyticsRepository;

  AnalyticsBloc({required AnalyticsRepository analyticsRepository})
      : _analyticsRepository = analyticsRepository,
        super(AnalyticsInitial()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
    on<GenerateSampleDataEvent>(_onGenerateSampleData);
    on<ResetMetricsEvent>(_onResetMetrics);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      final summary = _analyticsRepository.getAnalyticsSummary();
      final hitRate = _analyticsRepository.getHitRate();
      final totalSize = _analyticsRepository.getTotalSize();
      final mostFrequentlyAccessedKeys = _analyticsRepository.getMostFrequentlyAccessedKeys();
      final mostRecentlyAccessedKeys = _analyticsRepository.getMostRecentlyAccessedKeys();
      final largestItems = _analyticsRepository.getLargestItems();
      
      emit(AnalyticsLoaded(
        summary: summary,
        hitRate: hitRate,
        totalSize: totalSize,
        mostFrequentlyAccessedKeys: mostFrequentlyAccessedKeys,
        mostRecentlyAccessedKeys: mostRecentlyAccessedKeys,
        largestItems: largestItems,
      ));
    } catch (e) {
      emit(AnalyticsError('Failed to load analytics: ${e.toString()}'));
    }
  }

  Future<void> _onGenerateSampleData(
    GenerateSampleDataEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      await _analyticsRepository.generateSampleData();
      add(LoadAnalyticsEvent());
    } catch (e) {
      emit(AnalyticsError('Failed to generate sample data: ${e.toString()}'));
    }
  }

  Future<void> _onResetMetrics(
    ResetMetricsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      _analyticsRepository.resetMetrics();
      add(LoadAnalyticsEvent());
    } catch (e) {
      emit(AnalyticsError('Failed to reset metrics: ${e.toString()}'));
    }
  }
}
