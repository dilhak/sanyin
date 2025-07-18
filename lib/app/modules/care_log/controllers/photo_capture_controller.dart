import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/care_log_model.dart';
import '../../../services/database_service.dart';
import '../../../services/photo_service.dart';
import '../../client/models/client_model.dart';

class PhotoCaptureController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final PhotoService _photoService = PhotoService();
  
  final TextEditingController notesController = TextEditingController();
  final RxString selectedPhotoPath = RxString('');
  final RxBool isLoading = false.obs;
  
  late Client client;

  @override
  void onInit() {
    super.onInit();
    client = Get.arguments as Client;
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }

  Future<void> takePhoto() async {
    try {
      isLoading.value = true;
      final photoPath = await _photoService.takePhoto();
      
      if (photoPath != null) {
        selectedPhotoPath.value = photoPath;
      } else {
        Get.snackbar(
          'Cancelled',
          'Photo capture was cancelled',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[800],
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickFromGallery() async {
    try {
      isLoading.value = true;
      final photoPath = await _photoService.pickImageFromGallery();
      
      if (photoPath != null) {
        selectedPhotoPath.value = photoPath;
      } else {
        Get.snackbar(
          'Cancelled',
          'Photo selection was cancelled',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[800],
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick photo: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> savePhoto() async {
    if (selectedPhotoPath.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a photo first',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      final careLog = CareLog(
        clientId: client.id!,
        activityType: CareActivityType.photo,
        action: 'Photo captured',
        subAction: 'Photo with notes',
        photoPath: selectedPhotoPath.value,
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        timestamp: DateTime.now(),
      );

      await _databaseService.insertCareLog(careLog);
      
      Get.back();
      Get.snackbar(
        'Success',
        'Photo saved successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save photo: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }
} 