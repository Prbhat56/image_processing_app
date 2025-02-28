
import 'package:image_picker/image_picker.dart';
import 'package:image_processing_app/domain/entity/image_entity.dart';

abstract class ImageRepository {
  Future<ImageEntity> pickImage(ImageSource source);
  Future<ImageEntity> processImage(String imagePath, String filterType);
  Future<bool> saveImage(String imagePath);
  Future<ImageEntity> loadImageFromUrl(String url);
}