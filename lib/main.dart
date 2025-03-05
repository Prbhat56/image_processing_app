import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_processing_app/data/datasource/local_datasource.dart';
import 'package:image_processing_app/data/repositories/data_repositories.dart';
import 'package:image_processing_app/domain/usecases/image_url_save.dart';
import 'package:image_processing_app/domain/usecases/pick_image.dart';
import 'package:image_processing_app/domain/usecases/process_image.dart';
import 'package:image_processing_app/domain/usecases/process_image_without_isolate.dart';
import 'package:image_processing_app/domain/usecases/save_image.dart';

import 'package:image_processing_app/presentation/bloc/image_bloc.dart';
import 'package:image_processing_app/presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImageBloc(
        pickImage: PickImage(ImageRepositoryImpl(LocalDataSource())),
        processImage: ProcessImage(ImageRepositoryImpl(LocalDataSource())),
         processImageWithoutIsolate: ProcessImageWithoutIsolate(ImageRepositoryImpl(LocalDataSource())),
        saveImage: SaveImage(ImageRepositoryImpl(LocalDataSource())),
        loadImageFromUrl: LoadImageFromUrl(ImageRepositoryImpl(LocalDataSource())),
      ),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(), // Now HomePage is inside the BlocProvider
      ),
    );
  }
}
