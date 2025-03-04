import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart';
import 'dart:io';
import 'dart:isolate'; // Import for Isolate
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class LocalDataSource {
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<String> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      return pickedFile.path;
    }
    throw Exception('No image selected');
  }

  // Process image with filter using Isolate
  Future<String> processImage(String imagePath, String filterType) async {
    // Get the directory path in the main Isolate
    final directory = await getApplicationDocumentsDirectory();
    final outputPath = join(directory.path, 'processed_image.png');

    // Create a ReceivePort to receive messages from the Isolate
    final receivePort = ReceivePort();

    // Spawn a new Isolate
    await Isolate.spawn(
      _processImageInIsolate,
      {
        'imagePath': imagePath,
        'filterType': filterType,
        'outputPath': outputPath,
        'sendPort': receivePort.sendPort, // Pass the SendPort to the Isolate
      },
    );

    // Wait for the Isolate to send a message back
    await for (var message in receivePort) {
      if (message is String) {
        return message; // Return the output path
      } else if (message is Exception) {
        throw message; // Throw any exceptions from the Isolate
      }
    }

    throw Exception('Failed to process image');
  }

  // Save image to a permanent location
  Future<String> saveImage(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'saved_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedPath = join(directory.path, fileName);

      // Copy the file to the new location
      await File(imagePath).copy(savedPath);

      return savedPath;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  // Load image from URL
  Future<String> loadImageFromUrl(String url) async {
    try {
      // Validate the URL
      if (url.isEmpty || !Uri.parse(url).isAbsolute) {
        throw Exception('Invalid URL: $url');
      }

      // Make the HTTP request
      final response = await http.get(Uri.parse(url));

      // Check if the request was successful
      if (response.statusCode != 200) {
        throw Exception('Failed to download image: HTTP ${response.statusCode}');
      }

      // Get a temporary directory to store the downloaded image
      final directory = await getTemporaryDirectory();
      final fileName = 'url_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = join(directory.path, fileName);

      // Write the image data to a file
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

// Helper method to process image in isolate (must be top-level or static)
void _processImageInIsolate(Map<String, dynamic> params) {
  final imagePath = params['imagePath'] as String;
  final filterType = params['filterType'] as String;
  final outputPath = params['outputPath'] as String;
  final sendPort = params['sendPort'] as SendPort; // Get the SendPort from params

  try {
    // Decode the image from the file
    final image = decodeImage(File(imagePath).readAsBytesSync())!;

    // Apply the filter based on the filter type
    final processedImage = _applyFilter(image, filterType);

    // Save the processed image to the output path
    File(outputPath).writeAsBytesSync(encodePng(processedImage));

    // Send the output path back to the main Isolate
    sendPort.send(outputPath);
  } catch (e) {
    // Send any exceptions back to the main Isolate
    sendPort.send(Exception('Failed to process image in Isolate: $e'));
  }
}

// Helper method to apply filters (must be top-level or static)
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