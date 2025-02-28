




import 'package:image_processing_app/domain/entity/image_entity.dart';
import 'package:image_processing_app/domain/repositories/image_repositories.dart';

class ProcessImage {
  final ImageRepository repository;

  ProcessImage(this.repository);

  Future<ImageEntity> call(String imagePath, String filterType) async {
    return await repository.processImage(imagePath, filterType);
  }
}