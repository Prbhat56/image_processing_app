import 'package:image_processing_app/domain/entity/image_entity.dart';
import 'package:image_processing_app/domain/repositories/image_repositories.dart';

class ProcessImageWithoutIsolate {
  final ImageRepository repository;

  ProcessImageWithoutIsolate(this.repository);

  Future<ImageEntity> call(String imagePath, String filterType) async {
    return await repository.processImageWithoutIsolate(imagePath, filterType);
  }
}