import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_processing_app/presentation/bloc/image_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Processing App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<ImageBloc, ImageState>(
          builder: (context, state) {
            if (state is ImageInitial) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pick an image or paste a URL to start',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    _buildImageSourceOptions(context),
                  ],
                ),
              );
            } else if (state is ImageLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ImagePicked) {
              return Column(
                children: [
                  Expanded(
                    child: Image.file(
                      File(state.imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Apply filter with isolates
                      context.read<ImageBloc>().add(
                          ProcessImageEvent(state.imagePath, 'grayscale'));
                    },
                    child: const Text('Apply Grayscale with Isolates'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Apply filter without isolates and run heavy computation
                      _runHeavyComputation();
                      context.read<ImageBloc>().add(
                          ProcessImageEventWithoutIsolate(state.imagePath, 'grayscale'));
                    },
                    child: const Text('Apply Grayscale without Isolates'),
                  ),
                ],
              );
            } else if (state is ImageProcessed) {
              return Column(
                children: [
                  Expanded(
                    child: Image.file(
                      File(state.processedImagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ImageBloc>().add(
                          SaveImageEvent(state.processedImagePath));
                    },
                    child: const Text('Save Image'),
                  ),
                ],
              );
            } else if (state is ImageError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }
            return Container();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showImageSourceDialog(context);
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildImageSourceOptions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _showImageSourceDialog(context);
          },
          child: const Text('Select Image from Device'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            _showUrlInputDialog(context);
          },
          child: const Text('Paste Image URL'),
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ImageBloc>().add(PickImageEvent(ImageSource.gallery));
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ImageBloc>().add(PickImageEvent(ImageSource.camera));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUrlInputDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Paste Image URL'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: 'Enter image URL',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final url = urlController.text.trim();
                if (url.isNotEmpty) {
                  context.read<ImageBloc>().add(LoadImageFromUrlEvent(url));
                  Navigator.pop(context);
                }
              },
              child: const Text('Load'),
            ),
          ],
        );
      },
    );
  }

  // Function to simulate a heavy computation
  void _runHeavyComputation() {
    const int n = 1000000000; // 1 billion
    double sum = 0;

    final startTime = DateTime.now();
    for (int i = 1; i <= n; i++) {
      sum += i; // Add each number to the sum
    }
    final endTime = DateTime.now();

    print('Heavy computation result: $sum');
    print('Time taken: ${endTime.difference(startTime).inSeconds} seconds');
  }
}