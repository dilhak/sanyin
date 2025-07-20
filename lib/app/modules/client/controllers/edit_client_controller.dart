import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/client_model.dart';
import '../../../services/database_service.dart';
import '../../../core/error_handler.dart';
import '../../../core/validation.dart';
import '../../../widgets/universal_popup.dart';

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
  final RxString selectedHome = ''.obs;
  final RxList<String> availableHomes = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    client = Get.arguments as Client;
    nameController.text = client.name;
    addressController.text = client.address ?? '';
    selectedHome.value = client.address ?? '';
    _loadAvailableHomes();
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
        address: selectedHome.value.isEmpty ? null : selectedHome.value,
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

  Future<void> _loadAvailableHomes() async {
    try {
      final clients = await _databaseService.getClients();
      final homeSet = <String>{};
      
      for (final client in clients) {
        if (client.address != null && client.address!.isNotEmpty) {
          homeSet.add(client.address!);
        }
      }
      
      availableHomes.value = homeSet.toList()..sort();
    } catch (e) {
      // Handle error silently for now
      availableHomes.clear();
    }
  }

  void selectHome(String home) {
    selectedHome.value = home;
    addressController.text = home;
  }

  void showAddNewHomeDialog() {
    UniversalPopup.showInputDialog(
      title: 'Add New Home',
      hintText: 'Enter new home name',
      onConfirm: (homeName) {
        _addNewHomeFromDialog(homeName);
      },
    );
  }

  void _addNewHomeFromDialog(String homeName) {
    final newHome = homeName.trim();
    if (newHome.isEmpty) {
      _errorHandler.showWarningSnackbar('Please enter a home name');
      return;
    }

    if (availableHomes.contains(newHome)) {
      _errorHandler.showWarningSnackbar('This home already exists');
      return;
    }

    availableHomes.add(newHome);
    availableHomes.sort();
    selectedHome.value = newHome;
    addressController.text = newHome;
    
    _errorHandler.showSuccessSnackbar('New home added successfully');
  }
} 