import 'package:image_processing_app/domain/repositories/image_repositories.dart';

class SaveImage {
  final ImageRepository repository;
  
  SaveImage(this.repository);

  Future<bool> call(String imagePath) async {
    return await repository.saveImage(imagePath);
  }
}