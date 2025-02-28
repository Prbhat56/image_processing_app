part of 'image_bloc.dart';

abstract class ImageEvent extends Equatable {
  const ImageEvent();

  @override
  List<Object> get props => [];
}

class PickImageEvent extends ImageEvent {
  final ImageSource source;
  
  const PickImageEvent(this.source);
  
  @override
  List<Object> get props => [source];
}

class ProcessImageEvent extends ImageEvent {
  final String imagePath;
  final String filterType;
  
  const ProcessImageEvent(this.imagePath, this.filterType);
  
  @override
  List<Object> get props => [imagePath, filterType];
}

class SaveImageEvent extends ImageEvent {
  final String imagePath;
  
  const SaveImageEvent(this.imagePath);
  
  @override
  List<Object> get props => [imagePath];
}

class LoadImageFromUrlEvent extends ImageEvent {
  final String url;
  
  const LoadImageFromUrlEvent(this.url);
  
  @override
  List<Object> get props => [url];
}