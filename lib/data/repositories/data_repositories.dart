import 'package:image_picker/image_picker.dart';
import 'package:image_processing_app/data/datasource/local_datasource.dart';
import 'package:image_processing_app/domain/entity/image_entity.dart';
import 'package:image_processing_app/domain/repositories/image_repositories.dart';

class ImageRepositoryImpl implements ImageRepository {
  final LocalDataSource localDataSource;
  
  ImageRepositoryImpl(this.localDataSource);

  @override
  Future<ImageEntity> pickImage(ImageSource source) async {
    final path = await localDataSource.pickImage(source);
    return ImageEntity(path);
  }

  @override
  Future<ImageEntity> processImage(String imagePath, String filterType) async {
    final path = await localDataSource.processImage(imagePath, filterType);
    return ImageEntity(path);
  }

@override
Future<bool> saveImage(String imagePath) async {
  final result = await localDataSource.saveImage(imagePath);

  return result.isNotEmpty;
}

  @override
  Future<ImageEntity> loadImageFromUrl(String url) async {
    final path = await localDataSource.loadImageFromUrl(url);
    return ImageEntity(path);
  }
}