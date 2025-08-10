import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/home_model.dart';
import '../../../services/database_service.dart';
import '../../../core/error_handler.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/enhanced_text_field.dart';
import '../../../services/keyboard_service.dart';

class HomeController extends GetxController {
  final RxList<Home> homes = <Home>[].obs;
  final RxBool isLoading = false.obs;
  final DatabaseService _databaseService = DatabaseService();
  final ErrorHandler _errorHandler = ErrorHandler();

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    homes.clear();
    super.onClose();
  }

  Future<void> _initializeController() async {
    try {
      // Ensure database service is available
      await _databaseService.database;
      await loadHomes();
    } catch (e) {
      print('Failed to initialize home controller: $e');
      _errorHandler.logError(_errorHandler.categorizeError(e));
      isLoading.value = false;
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  Future<void> loadHomes() async {
    isLoading.value = true;
    try {
      final homesList = await _databaseService.getHomesWithClientCount();
      homes.value = homesList;
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    } finally {
      isLoading.value = false;
    }
  }

  void addNewHome() {
    final TextEditingController homeNameController = TextEditingController();
    final TextEditingController homeDescriptionController = TextEditingController();
    
    final FocusNode nameFocusNode = FocusNode();
    final FocusNode descriptionFocusNode = FocusNode();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.7,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add home icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade400,
                        Colors.blue.shade600,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Create New Home',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the details for the new care home',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Home name field
                EnhancedTextField(
                  controller: homeNameController,
                  focusNode: nameFocusNode,
                  hintText: 'Home Name',
                  prefixIcon: Icons.home,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => descriptionFocusNode.requestFocus(),
                ),
                const SizedBox(height: 16),
                // Description field
                EnhancedTextField(
                  controller: homeDescriptionController,
                  focusNode: descriptionFocusNode,
                  hintText: 'Description (Optional)',
                  prefixIcon: Icons.description,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => KeyboardService.to.dismissKeyboard(),
                ),
                const SizedBox(height: 32),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = homeNameController.text.trim();
                            if (name.isNotEmpty) {
                              Get.back();
                              await _addNewHome(name);
                            } else {
                              _errorHandler.showWarningSnackbar('Please enter a home name');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Create Home',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addNewHome(String homeName) async {
    // Check if home already exists
    if (homes.any((home) => home.name.toLowerCase() == homeName.toLowerCase())) {
      _errorHandler.showWarningSnackbar('Home "$homeName" already exists');
      return;
    }

    try {
      // Save home to database
      await _databaseService.insertHome(homeName);
      
      // Reload homes to get updated list with client counts
      await loadHomes();
      
      // Show success message
      _errorHandler.showSuccessSnackbar('Home "$homeName" created successfully');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  void editHome(Home home) {
    final TextEditingController homeNameController = TextEditingController(text: home.name);
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.6,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit home icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.orange.shade400,
                        Colors.orange.shade600,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Edit Home',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Update the home details',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Home name field
                EnhancedTextField(
                  controller: homeNameController,
                  hintText: 'Home Name',
                  prefixIcon: Icons.home,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.orange.shade400,
                              Colors.orange.shade600,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final newName = homeNameController.text.trim();
                            if (newName.isNotEmpty && newName != home.name) {
                              Get.back();
                              await _updateHome(home, newName);
                            } else if (newName.isEmpty) {
                              _errorHandler.showWarningSnackbar('Please enter a home name');
                            } else {
                              Get.back(); // No changes made
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Update Home',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateHome(Home home, String newName) async {
    // Check if new name already exists (excluding current home)
    if (homes.any((h) => h.id != home.id && h.name.toLowerCase() == newName.toLowerCase())) {
      _errorHandler.showWarningSnackbar('Home "$newName" already exists');
      return;
    }

    try {
      // Update home in database
      final updatedHome = home.copyWith(name: newName);
      await _databaseService.updateHome(updatedHome);
      
      // Reload homes to get updated list
      await loadHomes();
      
      // Show success message
      _errorHandler.showSuccessSnackbar('Home updated successfully');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  Future<void> deleteHome(Home home) async {
    if (home.clientCount != null && home.clientCount! > 0) {
      _errorHandler.showWarningSnackbar(
        'Cannot delete home "${home.name}" because it has ${home.clientCount} client(s). Please move or remove all clients first.'
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade600,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Delete Home',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${home.name}"? This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(result: false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ?? false;

    if (confirmed) {
      try {
        await _databaseService.deleteHomeById(home.id!);
        await loadHomes();
        _errorHandler.showSuccessSnackbar('Home "${home.name}" deleted successfully');
      } catch (e) {
        _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
      }
    }
  }

  void viewHomeClients(Home home) {
    Get.toNamed(Routes.CLIENT_DASHBOARD, arguments: {
      'selectedHome': home.name,
      'homeId': home.id,
    });
  }

  void refreshHomes() {
    loadHomes();
  }
}
