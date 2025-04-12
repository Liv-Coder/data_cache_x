import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/gallery_image.dart';
import '../../data/repositories/gallery_repository.dart';

// Events
abstract class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object> get props => [];
}

class LoadGalleryEvent extends GalleryEvent {}

class GenerateSampleImagesEvent extends GalleryEvent {
  final int count;

  const GenerateSampleImagesEvent({this.count = 10});

  @override
  List<Object> get props => [count];
}

class ToggleFavoriteEvent extends GalleryEvent {
  final String imageId;

  const ToggleFavoriteEvent(this.imageId);

  @override
  List<Object> get props => [imageId];
}

class DeleteImageEvent extends GalleryEvent {
  final String imageId;

  const DeleteImageEvent(this.imageId);

  @override
  List<Object> get props => [imageId];
}

class ClearGalleryEvent extends GalleryEvent {}

// States
abstract class GalleryState extends Equatable {
  const GalleryState();
  
  @override
  List<Object> get props => [];
}

class GalleryInitial extends GalleryState {}

class GalleryLoading extends GalleryState {}

class GalleryLoaded extends GalleryState {
  final List<GalleryImage> images;
  final int totalSize;
  final int imageCount;

  const GalleryLoaded({
    required this.images,
    required this.totalSize,
    required this.imageCount,
  });
  
  @override
  List<Object> get props => [images, totalSize, imageCount];
}

class GalleryError extends GalleryState {
  final String message;

  const GalleryError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Bloc
class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GalleryRepository _galleryRepository;

  GalleryBloc({required GalleryRepository galleryRepository})
      : _galleryRepository = galleryRepository,
        super(GalleryInitial()) {
    on<LoadGalleryEvent>(_onLoadGallery);
    on<GenerateSampleImagesEvent>(_onGenerateSampleImages);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<DeleteImageEvent>(_onDeleteImage);
    on<ClearGalleryEvent>(_onClearGallery);
  }

  Future<void> _onLoadGallery(
    LoadGalleryEvent event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    try {
      final images = await _galleryRepository.getImages();
      final totalSize = images.fold<int>(0, (sum, image) => sum + image.size);
      
      emit(GalleryLoaded(
        images: images,
        totalSize: totalSize,
        imageCount: images.length,
      ));
    } catch (e) {
      emit(GalleryError('Failed to load gallery: ${e.toString()}'));
    }
  }

  Future<void> _onGenerateSampleImages(
    GenerateSampleImagesEvent event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    try {
      await _galleryRepository.generateSampleImages(event.count);
      add(LoadGalleryEvent());
    } catch (e) {
      emit(GalleryError('Failed to generate sample images: ${e.toString()}'));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<GalleryState> emit,
  ) async {
    final currentState = state;
    if (currentState is GalleryLoaded) {
      try {
        await _galleryRepository.toggleFavorite(event.imageId);
        add(LoadGalleryEvent());
      } catch (e) {
        emit(GalleryError('Failed to toggle favorite: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteImage(
    DeleteImageEvent event,
    Emitter<GalleryState> emit,
  ) async {
    final currentState = state;
    if (currentState is GalleryLoaded) {
      try {
        await _galleryRepository.deleteImage(event.imageId);
        add(LoadGalleryEvent());
      } catch (e) {
        emit(GalleryError('Failed to delete image: ${e.toString()}'));
      }
    }
  }

  Future<void> _onClearGallery(
    ClearGalleryEvent event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    try {
      await _galleryRepository.clearGallery();
      add(LoadGalleryEvent());
    } catch (e) {
      emit(GalleryError('Failed to clear gallery: ${e.toString()}'));
    }
  }
}
