import 'package:image_picker/image_picker.dart';
import 'package:image_processing_app/domain/entity/image_entity.dart';
import 'package:image_processing_app/domain/repositories/image_repositories.dart';

class PickImage {
  final ImageRepository repository;
  
  PickImage(this.repository);

  Future<ImageEntity> call(ImageSource source) async {
    return await repository.pickImage(source);
  }
}