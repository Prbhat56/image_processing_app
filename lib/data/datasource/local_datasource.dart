import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:isolate';
import 'package:http/http.dart' as http;

class LocalDataSource {
  final ImagePicker _picker = ImagePicker();
  
  // Pick image from gallery (original method)
  Future<String> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      return pickedFile.path;
    }
    throw Exception('No image selected');
  }
  
  // Process image with filter (original method)
  Future<String> processImage(String imagePath, String filterType) async {
    final ReceivePort receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      _processImageInIsolate,
      _IsolateData(
        imagePath: imagePath,
        filterType: filterType,
        sendPort: receivePort.sendPort,
      ),
    );
    
    final processedImagePath = await receivePort.first as String;
    receivePort.close();
    isolate.kill();
    
    return processedImagePath;
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
      final response = await http.get(Uri.parse(url));
      
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
    } catch (e) {
      throw Exception('Failed to load image from URL: $e');
    }
  }
  
  // Helper method to process image in isolate (original method)
  static void _processImageInIsolate(_IsolateData isolateData) async {
    final image = decodeImage(File(isolateData.imagePath).readAsBytesSync())!;
    final processedImage = _applyFilter(image, isolateData.filterType);
    final directory = await getApplicationDocumentsDirectory();
    final savedPath = join(directory.path, 'processed_image.png');
    File(savedPath).writeAsBytesSync(encodePng(processedImage));
    
    isolateData.sendPort.send(savedPath);
  }
  
  // Helper method to apply filters (original method)
  static Image _applyFilter(Image image, String filterType) {
    switch (filterType) {
      case 'grayscale':
        return grayscale(image);
      case 'blur':
        return gaussianBlur(image, radius: 1);
      default:
        return image;
    }
  }
}

class _IsolateData {
  final String imagePath;
  final String filterType;
  final SendPort sendPort;
  
  _IsolateData({
    required this.imagePath,
    required this.filterType,
    required this.sendPort,
  });
}