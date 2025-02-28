import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_processing_app/data/datasource/local_datasource.dart';
import 'package:image_processing_app/data/repositories/data_repositories.dart';
import 'package:image_processing_app/domain/usecases/image_url_save.dart';
import 'package:image_processing_app/domain/usecases/pick_image.dart';
import 'package:image_processing_app/domain/usecases/process_image.dart';
import 'package:image_processing_app/domain/usecases/save_image.dart';

import 'package:image_processing_app/presentation/bloc/image_bloc.dart';
import 'package:image_processing_app/presentation/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => ImageBloc(
          pickImage: PickImage(ImageRepositoryImpl(LocalDataSource())),
          processImage: ProcessImage(ImageRepositoryImpl(LocalDataSource())),
          saveImage: SaveImage(ImageRepositoryImpl(LocalDataSource())),
          loadImageFromUrl: LoadImageFromUrl(ImageRepositoryImpl(LocalDataSource())),
        ),
        child: HomePage(), // Ensure HomePage is the child of BlocProvider
      ),
    );
  }
}