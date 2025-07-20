import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../core/error_handler.dart';

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
        throw AppError(
          message: 'Camera permission denied',
          type: ErrorType.permission,
        );
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Reduced from 80 to save memory
        maxWidth: 800, // Reduced from 1024 to save memory
        maxHeight: 800, // Reduced from 1024 to save memory
      );

      if (image != null) {
        return await _saveImageToLocal(image);
      }
      return null;
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        message: 'Failed to take photo',
        type: ErrorType.file,
        originalError: e,
      );
    }
  }

  Future<String?> pickImageFromGallery() async {
    try {
      // Request storage permission
      final status = await Permission.photos.request();
      if (status != PermissionStatus.granted) {
        throw AppError(
          message: 'Gallery permission denied',
          type: ErrorType.permission,
        );
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Reduced from 80 to save memory
        maxWidth: 800, // Reduced from 1024 to save memory
        maxHeight: 800, // Reduced from 1024 to save memory
      );

      if (image != null) {
        return await _saveImageToLocal(image);
      }
      return null;
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        message: 'Failed to pick image from gallery',
        type: ErrorType.file,
        originalError: e,
      );
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
      throw AppError(
        message: 'Failed to save image',
        type: ErrorType.file,
        originalError: e,
      );
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

  /// Clean up old photos to prevent storage bloat
  Future<void> cleanupOldPhotos({int maxPhotos = 100}) async {
    try {
      final paths = await getAllPhotoPaths();
      if (paths.length > maxPhotos) {
        // Sort by creation time (oldest first)
        final files = paths.map((path) => File(path)).toList();
        files.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
        
        // Delete oldest photos
        final toDelete = files.take(paths.length - maxPhotos);
        for (final file in toDelete) {
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  void dispose() {
    // Clean up any resources if needed
    // ImagePicker doesn't require explicit disposal, but we can add cleanup here if needed
  }
} 