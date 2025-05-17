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

class LoadTagsEvent extends GalleryEvent {}

class FilterByTagEvent extends GalleryEvent {
  final String tag;

  const FilterByTagEvent(this.tag);

  @override
  List<Object> get props => [tag];
}

class ClearTagFilterEvent extends GalleryEvent {}

class AddTagEvent extends GalleryEvent {
  final String imageId;
  final String tag;

  const AddTagEvent({required this.imageId, required this.tag});

  @override
  List<Object> get props => [imageId, tag];
}

class RemoveTagEvent extends GalleryEvent {
  final String imageId;
  final String tag;

  const RemoveTagEvent({required this.imageId, required this.tag});

  @override
  List<Object> get props => [imageId, tag];
}

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
  final Set<String> availableTags;
  final String? activeTagFilter;

  const GalleryLoaded({
    required this.images,
    required this.totalSize,
    required this.imageCount,
    this.availableTags = const {},
    this.activeTagFilter,
  });

  @override
  List<Object> get props => [
        images,
        totalSize,
        imageCount,
        availableTags,
        if (activeTagFilter != null) activeTagFilter!,
      ];

  GalleryLoaded copyWith({
    List<GalleryImage>? images,
    int? totalSize,
    int? imageCount,
    Set<String>? availableTags,
    String? activeTagFilter,
    bool clearTagFilter = false,
  }) {
    return GalleryLoaded(
      images: images ?? this.images,
      totalSize: totalSize ?? this.totalSize,
      imageCount: imageCount ?? this.imageCount,
      availableTags: availableTags ?? this.availableTags,
      activeTagFilter:
          clearTagFilter ? null : (activeTagFilter ?? this.activeTagFilter),
    );
  }
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
    on<LoadTagsEvent>(_onLoadTags);
    on<FilterByTagEvent>(_onFilterByTag);
    on<ClearTagFilterEvent>(_onClearTagFilter);
    on<AddTagEvent>(_onAddTag);
    on<RemoveTagEvent>(_onRemoveTag);
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
      final tags = await _galleryRepository.getAllTags();

      emit(GalleryLoaded(
        images: images,
        totalSize: totalSize,
        imageCount: images.length,
        availableTags: tags,
      ));
    } catch (e) {
      emit(GalleryError('Failed to load gallery: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTags(
    LoadTagsEvent event,
    Emitter<GalleryState> emit,
  ) async {
    if (state is GalleryLoaded) {
      try {
        final tags = await _galleryRepository.getAllTags();
        emit((state as GalleryLoaded).copyWith(availableTags: tags));
      } catch (e) {
        emit(GalleryError('Failed to load tags: ${e.toString()}'));
      }
    }
  }

  Future<void> _onFilterByTag(
    FilterByTagEvent event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    try {
      final images = await _galleryRepository.getImagesByTag(event.tag);
      final totalSize = images.fold<int>(0, (sum, image) => sum + image.size);
      final tags = await _galleryRepository.getAllTags();

      emit(GalleryLoaded(
        images: images,
        totalSize: totalSize,
        imageCount: images.length,
        availableTags: tags,
        activeTagFilter: event.tag,
      ));
    } catch (e) {
      emit(GalleryError('Failed to filter by tag: ${e.toString()}'));
    }
  }

  Future<void> _onClearTagFilter(
    ClearTagFilterEvent event,
    Emitter<GalleryState> emit,
  ) async {
    add(LoadGalleryEvent());
  }

  Future<void> _onAddTag(
    AddTagEvent event,
    Emitter<GalleryState> emit,
  ) async {
    try {
      await _galleryRepository.addTagToImage(event.imageId, event.tag);

      if (state is GalleryLoaded) {
        final currentState = state as GalleryLoaded;
        if (currentState.activeTagFilter != null) {
          add(FilterByTagEvent(currentState.activeTagFilter!));
        } else {
          add(LoadGalleryEvent());
        }
      }
    } catch (e) {
      emit(GalleryError('Failed to add tag: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveTag(
    RemoveTagEvent event,
    Emitter<GalleryState> emit,
  ) async {
    try {
      await _galleryRepository.removeTagFromImage(event.imageId, event.tag);

      if (state is GalleryLoaded) {
        final currentState = state as GalleryLoaded;
        if (currentState.activeTagFilter != null) {
          add(FilterByTagEvent(currentState.activeTagFilter!));
        } else {
          add(LoadGalleryEvent());
        }
      }
    } catch (e) {
      emit(GalleryError('Failed to remove tag: ${e.toString()}'));
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
