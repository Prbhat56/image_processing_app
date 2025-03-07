import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart';
import 'dart:io';
import 'dart:isolate';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class LocalDataSource {
  final ImagePicker _picker = ImagePicker();

  Future<String> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      return pickedFile.path;
    }
    throw Exception('No image selected');
  }

  // Function to process image WITH isolates
  Future<String> processImage(String imagePath, String filterType) async {
    final directory = await getApplicationDocumentsDirectory();
    final outputPath = join(directory.path, 'processed_image.png');

    final receivePort = ReceivePort();
    print(4);
    await Isolate.spawn(
      _processImageInIsolate,
      {
        'imagePath': imagePath,
        'filterType': filterType,
        'outputPath': outputPath,
        'sendPort': receivePort.sendPort,
      },
    );
    print(2);
    
    await for (var message in receivePort) {
      if (message is String) {
        print(3);
        return message;
      } else if (message is Exception) {
        throw message;
      }
    }
    print(5);
    throw Exception('Failed to process image');
  }

  Future<String> processImageWithoutIsolate(
      String imagePath, String filterType) async {
    try {
      // Load the image
      final image = decodeImage(File(imagePath).readAsBytesSync())!;

      // Apply the filter
      final processedImage = _applyFilter(image, filterType);

      // Save the processed image
      final directory = await getApplicationDocumentsDirectory();
      final outputPath = join(directory.path, 'processed_image_no_isolate.png');
      File(outputPath).writeAsBytesSync(encodePng(processedImage));

      return outputPath;
    } catch (e) {
      throw Exception('Failed to process image without Isolate: $e');
    }
  }

  Future<String> saveImage(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'saved_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedPath = join(directory.path, fileName);

      await File(imagePath).copy(savedPath);

      return savedPath;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  Future<String> loadImageFromUrl(String url) async {
    try {
      if (url.isEmpty || !Uri.parse(url).isAbsolute) {
        throw Exception('Invalid URL: $url');
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to download image: HTTP ${response.statusCode}');
      }

      final directory = await getTemporaryDirectory();
      final fileName = 'url_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = join(directory.path, fileName);

      await File(filePath).writeAsBytes(response.bodyBytes);

      return filePath;
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      throw Exception('Failed to load image: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid image data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load image from URL: $e');
    }
  }
}

void _processImageInIsolate(Map<String, dynamic> params) {
  final imagePath = params['imagePath'] as String;
  final filterType = params['filterType'] as String;
  final outputPath = params['outputPath'] as String;
  final sendPort = params['sendPort'] as SendPort;

  try {
    // Load the image
    final image = decodeImage(File(imagePath).readAsBytesSync())!;

    // Apply the filter
    final processedImage = _applyFilter(image, filterType);
    print(1);
    // Save the processed image
    File(outputPath).writeAsBytesSync(encodePng(processedImage));

    // Send the result back
    sendPort.send(outputPath);
  } catch (e) {
    // Send the error back
    sendPort.send(Exception('Failed to process image in Isolate: $e'));
  }
}

Image _applyFilter(Image image, String filterType) {
  switch (filterType) {
    case 'grayscale':
      return grayscale(image);
    case 'blur':
      return gaussianBlur(image, radius: 1);
    default:
      return image;
  }
}
