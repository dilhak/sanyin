import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/client_model.dart';
import '../../../services/database_service.dart';
import '../../../core/error_handler.dart';
import '../../../core/validation.dart';

class EditClientController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final ErrorHandler _errorHandler = ErrorHandler();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  
  // Focus nodes for better keyboard navigation
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode addressFocusNode = FocusNode();

  late Client client;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    client = Get.arguments as Client;
    nameController.text = client.name;
    addressController.text = client.address ?? '';
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    
    // Dispose focus nodes
    nameFocusNode.dispose();
    addressFocusNode.dispose();
    
    super.onClose();
  }

  Future<void> updateClient() async {
    if (!_validateForm()) {
      return;
    }

    isLoading.value = true;
    try {
      final updatedClient = Client(
        id: client.id,
        name: nameController.text.trim(),
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        phoneNumber: client.phoneNumber,
        emergencyContact: client.emergencyContact,
        medicalNotes: client.medicalNotes,
        createdAt: client.createdAt,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateClient(updatedClient);
      
      Get.back();
      _errorHandler.showSuccessSnackbar('Client updated successfully');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    final nameError = Validation.validateName(nameController.text);
    if (nameError != null) {
      _errorHandler.showWarningSnackbar(nameError);
      return false;
    }
    
    return true;
  }
} 