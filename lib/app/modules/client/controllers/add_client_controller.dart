import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/client_model.dart';
import '../../../services/database_service.dart';
import '../controllers/client_dashboard_controller.dart';
import '../../../core/error_handler.dart';
import '../../../core/validation.dart';

class AddClientController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final ErrorHandler _errorHandler = ErrorHandler();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emergencyContactController = TextEditingController();
  final TextEditingController medicalNotesController = TextEditingController();
  
  // Focus nodes for better keyboard navigation
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode addressFocusNode = FocusNode();
  final FocusNode emergencyContactFocusNode = FocusNode();
  final FocusNode medicalNotesFocusNode = FocusNode();

  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emergencyContactController.dispose();
    medicalNotesController.dispose();
    
    // Dispose focus nodes
    nameFocusNode.dispose();
    phoneFocusNode.dispose();
    addressFocusNode.dispose();
    emergencyContactFocusNode.dispose();
    medicalNotesFocusNode.dispose();
    
    super.onClose();
  }

  Future<void> saveClient() async {
    if (!_validateForm()) {
      return;
    }

    isLoading.value = true;
    try {
      final client = Client(
        name: nameController.text.trim(),
        phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        emergencyContact: emergencyContactController.text.trim().isEmpty ? null : emergencyContactController.text.trim(),
        medicalNotes: medicalNotesController.text.trim().isEmpty ? null : medicalNotesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.insertClient(client);
      
      // Refresh the client dashboard
      final clientDashboardController = Get.find<ClientDashboardController>();
      await clientDashboardController.loadClients();
      
      Get.back();
      _errorHandler.showSuccessSnackbar('Client added successfully');
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
    
    final phoneError = Validation.validatePhone(phoneController.text);
    if (phoneError != null) {
      _errorHandler.showWarningSnackbar(phoneError);
      return false;
    }
    
    final notesError = Validation.validateNotes(medicalNotesController.text);
    if (notesError != null) {
      _errorHandler.showWarningSnackbar(notesError);
      return false;
    }
    
    return true;
  }
} 