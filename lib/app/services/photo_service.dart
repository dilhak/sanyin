import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PhotoService {
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<String?> takePhoto() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Camera permission denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        return await _saveImageToLocal(image);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> pickImageFromGallery() async {
    try {
      // Request storage permission
      final status = await Permission.photos.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Gallery permission denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        return await _saveImageToLocal(image);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _saveImageToLocal(XFile image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/care_photos');
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = 'care_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = File('${imagesDir.path}/$fileName');
      
      await savedImage.writeAsBytes(await image.readAsBytes());
      
      return savedImage.path;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  Future<void> deletePhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors when deleting photos
    }
  }

  Future<List<String>> getAllPhotoPaths() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/care_photos');
      
      if (!await imagesDir.exists()) {
        return [];
      }

      final files = await imagesDir.list().toList();
      return files
          .where((file) => file is File && path.extension(file.path).toLowerCase() == '.jpg')
          .map((file) => file.path)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> getPhotoCount() async {
    final paths = await getAllPhotoPaths();
    return paths.length;
  }

  Future<String> getPhotoSize() async {
    try {
      final paths = await getAllPhotoPaths();
      int totalSize = 0;
      
      for (final photoPath in paths) {
        final file = File(photoPath);
        if (await file.exists()) {
          totalSize += await file.length();
        }
      }
      
      if (totalSize < 1024) {
        return '${totalSize}B';
      } else if (totalSize < 1024 * 1024) {
        return '${(totalSize / 1024).toStringAsFixed(1)}KB';
      } else {
        return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
      }
    } catch (e) {
      return '0B';
    }
  }
} 