import 'package:image_processing_app/domain/entity/image_entity.dart';
import 'package:image_processing_app/domain/repositories/image_repositories.dart';

class LoadImageFromUrl {
  final ImageRepository repository;
  
  LoadImageFromUrl(this.repository);

  Future<ImageEntity> call(String url) async {
    return await repository.loadImageFromUrl(url);
  }
}