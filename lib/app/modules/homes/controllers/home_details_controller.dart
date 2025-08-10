import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/home_model.dart';
import '../../../services/database_service.dart';
import '../../../core/error_handler.dart';
import '../../client/models/client_model.dart';
import '../../../routes/app_pages.dart';
import '../../facility_logs/models/facility_log_model.dart';

class HomeDetailsController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final ErrorHandler _errorHandler = ErrorHandler();
  
  final Rx<Home?> currentHome = Rx<Home?>(null);
  final RxList<Client> homeClients = <Client>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingClients = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFromArguments();
  }

  void _initializeFromArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['home'] != null) {
      currentHome.value = args['home'] as Home;
      loadHomeClients();
      
      // Log that the home details were viewed
      Future.delayed(const Duration(milliseconds: 500), () {
        logHomeViewed();
      });
    }
  }

  Future<void> loadHomeClients() async {
    if (currentHome.value == null) return;
    
    isLoadingClients.value = true;
    try {
      final clients = await _databaseService.getClientsByHome(currentHome.value!.name);
      homeClients.value = clients;
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    } finally {
      isLoadingClients.value = false;
    }
  }

  Future<void> refreshHome() async {
    if (currentHome.value == null) return;
    
    isLoading.value = true;
    try {
      final updatedHome = await _databaseService.getHomeByName(currentHome.value!.name);
      if (updatedHome != null) {
        currentHome.value = updatedHome;
      }
      await loadHomeClients();
      
      // Log the refresh action
      logHomeRefresh();
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToClients() {
    if (currentHome.value == null) return;
    
    // Log the navigation action
    _logHomeAction(
      'Clients Access',
      'Accessed client management for home: ${currentHome.value!.name}',
      FacilityLogType.other,
      FacilityLogPriority.low,
    );
    
    Get.toNamed(Routes.CLIENT_DASHBOARD, arguments: {
      'selectedHome': currentHome.value!.name,
      'homeId': currentHome.value!.id,
    });
  }

  void navigateToFacilityLogs() {
    if (currentHome.value == null) return;
    
    // Log the navigation action
    _logHomeAction(
      'Facility Logs Access',
      'Accessed facility logs for home: ${currentHome.value!.name}',
      FacilityLogType.other,
      FacilityLogPriority.low,
    );
    
    Get.toNamed(Routes.FACILITY_LOGS, arguments: {
      'homeId': currentHome.value!.id,
      'homeName': currentHome.value!.name,
    });
  }

  void editHome() {
    if (currentHome.value == null) return;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Home',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: TextEditingController(text: currentHome.value!.name),
                decoration: const InputDecoration(
                  labelText: 'Home Name',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (newName) {
                  if (newName.isNotEmpty && newName != currentHome.value!.name) {
                    _updateHomeName(newName);
                  }
                  Get.back();
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // This would be handled by onSubmitted above
                        Get.back();
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateHomeName(String newName) async {
    if (currentHome.value == null) return;
    
    try {
      final oldName = currentHome.value!.name;
      final updatedHome = currentHome.value!.copyWith(name: newName);
      await _databaseService.updateHome(updatedHome);
      currentHome.value = updatedHome;
      
      // Log the home update action
      _logHomeAction(
        'Home Updated',
        'Home name changed from "$oldName" to "$newName"',
        FacilityLogType.other,
        FacilityLogPriority.medium,
        additionalData: {
          'oldName': oldName,
          'newName': newName,
          'action': 'rename',
        },
      );
      
      _errorHandler.showSuccessSnackbar('Home updated successfully');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  void deleteHome() {
    if (currentHome.value == null) return;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Home'),
        content: Text(
          'Are you sure you want to delete "${currentHome.value!.name}"?\n\n'
          'This will also remove all associated clients and data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _deleteHome();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHome() async {
    if (currentHome.value == null) return;
    
    try {
      final homeName = currentHome.value!.name;
      final homeId = currentHome.value!.id!;
      
      // Log the deletion action before deleting (so we still have home context)
      _logHomeAction(
        'Home Deleted',
        'Home "$homeName" was permanently deleted',
        FacilityLogType.other,
        FacilityLogPriority.high,
        additionalData: {
          'homeName': homeName,
          'homeId': homeId,
          'action': 'delete',
          'clientCount': homeClients.length,
        },
      );
      
      await _databaseService.deleteHomeById(homeId);
      _errorHandler.showSuccessSnackbar('Home deleted successfully');
      Get.back(); // Return to homes list
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  @override
  void onClose() {
    homeClients.clear();
    currentHome.value = null;
    super.onClose();
  }

  // Logging Methods for Home Actions
  Future<void> _logHomeAction(
    String action,
    String description,
    FacilityLogType type,
    FacilityLogPriority priority, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (currentHome.value == null) return;

      final log = FacilityLog(
        homeId: currentHome.value!.id ?? 0,
        action: action,
        description: description,
        timestamp: DateTime.now(),
        type: type,
        priority: priority,
        staffMember: 'Current User', // TODO: Get actual user from auth service
        location: currentHome.value!.name,
        additionalData: additionalData,
      );

      await _databaseService.insertFacilityLog(log);
      print('Home Action Logged: $action - $description');
    } catch (e) {
      print('Failed to log home action: $e');
      // Don't show error to user for logging failures, just log it
      _errorHandler.logError(_errorHandler.categorizeError(e));
    }
  }

  void logHomeViewed() {
    _logHomeAction(
      'Home Viewed',
      'Viewed details for home: ${currentHome.value?.name ?? "Unknown"}',
      FacilityLogType.other,
      FacilityLogPriority.low,
      additionalData: {
        'action': 'view_details',
        'clientCount': homeClients.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  void logHomeRefresh() {
    _logHomeAction(
      'Home Refreshed',
      'Refreshed data for home: ${currentHome.value?.name ?? "Unknown"}',
      FacilityLogType.other,
      FacilityLogPriority.low,
      additionalData: {
        'action': 'refresh_data',
        'clientCount': homeClients.length,
      },
    );
  }
}
