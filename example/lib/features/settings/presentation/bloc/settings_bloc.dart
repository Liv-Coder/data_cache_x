import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cache_settings.dart';
import '../../data/repositories/settings_repository.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class UpdateSettingsEvent extends SettingsEvent {
  final CacheSettings settings;

  const UpdateSettingsEvent(this.settings);

  @override
  List<Object> get props => [settings];
}

class ApplySettingsEvent extends SettingsEvent {
  final CacheSettings settings;

  const ApplySettingsEvent(this.settings);

  @override
  List<Object> get props => [settings];
}

class ResetSettingsEvent extends SettingsEvent {}

class LoadMetricsEvent extends SettingsEvent {}

class ResetMetricsEvent extends SettingsEvent {}

class ClearCacheEvent extends SettingsEvent {}

// States
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final CacheSettings settings;
  final Map<String, dynamic>? metrics;

  const SettingsLoaded({
    required this.settings,
    this.metrics,
  });

  @override
  List<Object> get props => [settings, if (metrics != null) metrics!];
}

class SettingsUpdated extends SettingsState {
  final CacheSettings settings;

  const SettingsUpdated(this.settings);

  @override
  List<Object> get props => [settings];
}

class SettingsApplied extends SettingsState {
  final CacheSettings settings;

  const SettingsApplied(this.settings);

  @override
  List<Object> get props => [settings];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository,
        super(SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateSettingsEvent>(_onUpdateSettings);
    on<ApplySettingsEvent>(_onApplySettings);
    on<ResetSettingsEvent>(_onResetSettings);
    on<LoadMetricsEvent>(_onLoadMetrics);
    on<ResetMetricsEvent>(_onResetMetrics);
    on<ClearCacheEvent>(_onClearCache);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final settings = await _settingsRepository.getSettings();
      final metrics = await _settingsRepository.getCacheMetrics();

      emit(SettingsLoaded(
        settings: settings,
        metrics: metrics,
      ));
    } catch (e) {
      emit(SettingsError('Failed to load settings: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateSettings(
    UpdateSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      await _settingsRepository.saveSettings(event.settings);

      emit(SettingsUpdated(event.settings));
      add(LoadSettingsEvent());
    } catch (e) {
      emit(SettingsError('Failed to update settings: ${e.toString()}'));
    }
  }

  Future<void> _onApplySettings(
    ApplySettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      await _settingsRepository.applySettings(event.settings);

      emit(SettingsApplied(event.settings));
      add(LoadSettingsEvent());
    } catch (e) {
      emit(SettingsError('Failed to apply settings: ${e.toString()}'));
    }
  }

  Future<void> _onResetSettings(
    ResetSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      await _settingsRepository.resetSettings();

      final settings = await _settingsRepository.getSettings();
      emit(SettingsUpdated(settings));
      add(LoadSettingsEvent());
    } catch (e) {
      emit(SettingsError('Failed to reset settings: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMetrics(
    LoadMetricsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(SettingsLoading());
      try {
        final metrics = await _settingsRepository.getCacheMetrics();

        emit(SettingsLoaded(
          settings: currentState.settings,
          metrics: metrics,
        ));
      } catch (e) {
        emit(SettingsError('Failed to load metrics: ${e.toString()}'));
      }
    }
  }

  Future<void> _onResetMetrics(
    ResetMetricsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(SettingsLoading());
      try {
        await _settingsRepository.resetMetrics();

        final metrics = await _settingsRepository.getCacheMetrics();

        emit(SettingsLoaded(
          settings: currentState.settings,
          metrics: metrics,
        ));
      } catch (e) {
        emit(SettingsError('Failed to reset metrics: ${e.toString()}'));
      }
    }
  }

  Future<void> _onClearCache(
    ClearCacheEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(SettingsLoading());
      try {
        await _settingsRepository.clearCache();

        final metrics = await _settingsRepository.getCacheMetrics();

        emit(SettingsLoaded(
          settings: currentState.settings,
          metrics: metrics,
        ));
      } catch (e) {
        emit(SettingsError('Failed to clear cache: ${e.toString()}'));
      }
    }
  }
}
