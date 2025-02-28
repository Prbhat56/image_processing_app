part of 'image_bloc.dart';

abstract class ImageState extends Equatable {
  const ImageState();
  
  @override
  List<Object> get props => [];
}

class ImageInitial extends ImageState {}

class ImageLoading extends ImageState {}

class ImagePicked extends ImageState {
  final String imagePath;
  
  const ImagePicked(this.imagePath);
  
  @override
  List<Object> get props => [imagePath];
}

class ImageProcessed extends ImageState {
  final String processedImagePath;
  
  const ImageProcessed(this.processedImagePath);
  
  @override
  List<Object> get props => [processedImagePath];
}

class ImageError extends ImageState {
  final String message;
  
  const ImageError(this.message);
  
  @override
  List<Object> get props => [message];
}