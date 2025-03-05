import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_processing_app/domain/usecases/image_url_save.dart';
import 'package:image_processing_app/domain/usecases/pick_image.dart';
import 'package:image_processing_app/domain/usecases/process_image.dart';
import 'package:image_processing_app/domain/usecases/process_image_without_isolate.dart';
import 'package:image_processing_app/domain/usecases/save_image.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final PickImage pickImage;
  final ProcessImage processImage;
  final SaveImage saveImage;
  final LoadImageFromUrl loadImageFromUrl;
  final ProcessImageWithoutIsolate processImageWithoutIsolate;

  ImageBloc({
    required this.pickImage,
    required this.processImage,
    required this.saveImage,
    required this.loadImageFromUrl,
    required this.processImageWithoutIsolate,
  }) : super(ImageInitial()) {
    on<PickImageEvent>(_onPickImage);
    on<ProcessImageEvent>(_onProcessImage);
     on<ProcessImageEventWithoutIsolate>(_onProcessImageWithoutIsolate);
    on<SaveImageEvent>(_onSaveImage);
    on<LoadImageFromUrlEvent>(_onLoadImageFromUrl);
  }

  void _onPickImage(PickImageEvent event, Emitter<ImageState> emit) async {
    emit(ImageLoading());
    try {
      final imageEntity = await pickImage(event.source);
      emit(ImagePicked(imageEntity.path));
    } catch (e) {
      emit(ImageError('Failed to pick image: $e'));
    }
  }

  void _onProcessImage(
      ProcessImageEvent event, Emitter<ImageState> emit) async {
    emit(ImageLoading());
    try {
      final imageEntity = await processImage(event.imagePath, event.filterType);
      emit(ImageProcessed(imageEntity.path));
    } catch (e) {
      emit(ImageError('Failed to process image: $e'));
    }
  }
   void _onProcessImageWithoutIsolate(
      ProcessImageEventWithoutIsolate event, Emitter<ImageState> emit) async {
    emit(ImageLoading());
    try {
      final imageEntity = await processImageWithoutIsolate(event.imagePath, event.filterType);
      emit(ImageProcessed(imageEntity.path));
    } catch (e) {
      emit(ImageError('Failed to process image: $e'));
    }
  }

  void _onSaveImage(SaveImageEvent event, Emitter<ImageState> emit) async {
    emit(ImageLoading());
    try {
      await saveImage(event.imagePath);
      emit(ImageInitial()); // Return to initial state after saving
    } catch (e) {
      emit(ImageError('Failed to save image: $e'));
    }
  }

  void _onLoadImageFromUrl(
      LoadImageFromUrlEvent event, Emitter<ImageState> emit) async {
    emit(ImageLoading());
    try {
      final imageEntity = await loadImageFromUrl(event.url);
      emit(ImagePicked(imageEntity.path));
    } catch (e) {
      emit(ImageError('Failed to load image from URL: $e'));
    }
  }
}
