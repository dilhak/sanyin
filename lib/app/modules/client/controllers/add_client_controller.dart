import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/client_model.dart';
import '../../../services/database_service.dart';
import '../controllers/client_dashboard_controller.dart';

class AddClientController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  
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
      Get.snackbar(
        'Success',
        'Client added successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add client: $e',
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

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter the client name',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }
    return true;
  }
} 