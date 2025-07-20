import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/care_log_model.dart';
import '../../../services/database_service.dart';
import '../../../services/photo_service.dart';
import '../../client/models/client_model.dart';
import '../controllers/care_log_history_controller.dart';
import '../../../core/error_handler.dart';

class PhotoCaptureController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final PhotoService _photoService = PhotoService();
  final ErrorHandler _errorHandler = ErrorHandler();
  
  final TextEditingController notesController = TextEditingController();
  final FocusNode notesFocusNode = FocusNode();
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
    notesFocusNode.dispose();
    
    // Clear reactive variables to prevent memory leaks
    selectedPhotoPath.value = '';
    isLoading.value = false;
    
    super.onClose();
  }

  /// Clean up photo resources
  Future<void> cleanupPhoto() async {
    if (selectedPhotoPath.value.isNotEmpty) {
      try {
        await _photoService.deletePhoto(selectedPhotoPath.value);
        selectedPhotoPath.value = '';
      } catch (e) {
        // Ignore cleanup errors
      }
    }
  }

  Future<void> takePhoto() async {
    try {
      isLoading.value = true;
      final photoPath = await _photoService.takePhoto();
      
      if (photoPath != null) {
        selectedPhotoPath.value = photoPath;
      } else {
        _errorHandler.showWarningSnackbar('Photo capture was cancelled');
      }
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
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
        _errorHandler.showWarningSnackbar('Photo selection was cancelled');
      }
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> savePhoto() async {
    if (selectedPhotoPath.value.isEmpty) {
      _errorHandler.showWarningSnackbar('Please select a photo first');
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
      
      // Refresh care log history if it exists
      try {
        final careLogHistoryController = Get.find<CareLogHistoryController>();
        await careLogHistoryController.loadCareLogs();
      } catch (e) {
        // Care log history controller not found, that's okay
      }
      
      Get.back();
      _errorHandler.showSuccessSnackbar('Photo saved successfully');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    } finally {
      isLoading.value = false;
    }
  }
} 