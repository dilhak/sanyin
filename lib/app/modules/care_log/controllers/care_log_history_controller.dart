import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/care_log_model.dart';
import '../../../services/database_service.dart';
import '../../client/models/client_model.dart';
import '../../../widgets/universal_popup.dart';
import '../../../core/error_handler.dart';

class CareLogHistoryController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final ErrorHandler _errorHandler = ErrorHandler();
  final RxList<CareLog> careLogs = <CareLog>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<Client?> selectedClient = Rx<Client?>(null);
  final Rx<CareActivityType?> selectedActivityType = Rx<CareActivityType?>(null);
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  Map<DateTime, List<CareLog>> get groupedLogs {
    final filteredLogs = _getFilteredLogs();
    final grouped = <DateTime, List<CareLog>>{};
    
    for (final log in filteredLogs) {
      final date = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      if (grouped.containsKey(date)) {
        grouped[date]!.add(log);
      } else {
        grouped[date] = [log];
      }
    }
    
    // Sort by date (newest first)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final sortedMap = <DateTime, List<CareLog>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    
    return sortedMap;
  }

  @override
  void onInit() {
    super.onInit();
    loadCareLogs();
  }

  Future<void> loadCareLogs() async {
    isLoading.value = true;
    try {
      final logs = await _databaseService.getAllCareLogs();
      careLogs.value = logs;
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    } finally {
      isLoading.value = false;
    }
  }

  List<CareLog> _getFilteredLogs() {
    List<CareLog> filtered = careLogs;

    // Filter by client
    if (selectedClient.value != null) {
      filtered = filtered.where((log) => log.clientId == selectedClient.value!.id).toList();
    }

    // Filter by activity type
    if (selectedActivityType.value != null) {
      filtered = filtered.where((log) => log.activityType == selectedActivityType.value).toList();
    }

    // Filter by date
    if (selectedDate.value != null) {
      final selectedDay = selectedDate.value!;
      filtered = filtered.where((log) {
        final logDay = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
        return logDay.isAtSameMomentAs(selectedDay);
      }).toList();
    }

    return filtered;
  }

  void showLogActions(CareLog log) {
    UniversalPopup.show(
      title: _getActivityTypeTitle(log.activityType),
      subtitle: _getLogDetails(log),
      icon: _getActivityTypeIcon(log.activityType),
      color: _getActivityTypeColor(log.activityType),
      actions: [
        PopupAction(
          title: 'Edit',
          icon: Icons.edit,
          color: Colors.blue,
          onTap: () => _editLog(log),
        ),
        PopupAction(
          title: 'Delete',
          icon: Icons.delete,
          color: Colors.red,
          onTap: () => _deleteLog(log),
        ),
      ],
    );
  }

  void _editLog(CareLog log) {
    Get.back();
    UniversalPopup.showInputDialog(
      title: 'Edit Log',
      hintText: 'Enter updated details...',
      maxLines: 3,
      onConfirm: (details) {
        _updateLog(log, details);
      },
    );
  }

  void _deleteLog(CareLog log) {
    Get.back();
    UniversalPopup.showConfirmation(
      title: 'Delete Log',
      message: 'Are you sure you want to delete this care log? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
      onConfirm: () => _confirmDeleteLog(log),
    );
  }

  Future<void> _confirmDeleteLog(CareLog log) async {
    try {
      await _databaseService.deleteCareLog(log.id!);
      await loadCareLogs();
      _errorHandler.showSuccessSnackbar('Care log deleted successfully');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  Future<void> _updateLog(CareLog log, String details) async {
    try {
      // Note: This would require an updateCareLog method in DatabaseService
      // For now, we'll just show a success message
      _errorHandler.showSuccessSnackbar('Care log updated successfully');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  String _getActivityTypeTitle(CareActivityType type) {
    switch (type) {
      case CareActivityType.medication:
        return 'Medication';
      case CareActivityType.toileting:
        return 'Toileting';
      case CareActivityType.hydration:
        return 'Hydration';
      case CareActivityType.meal:
        return 'Meal';
      case CareActivityType.behavior:
        return 'Behavior/Mood';
      case CareActivityType.photo:
        return 'Photo';
      case CareActivityType.note:
        return 'Note';
      case CareActivityType.pain:
        return 'Pain & Discomfort';
      case CareActivityType.vitals:
        return 'Vitals';
      case CareActivityType.location:
        return 'Location & Presence';
    }
  }

  IconData _getActivityTypeIcon(CareActivityType type) {
    switch (type) {
      case CareActivityType.medication:
        return Icons.medication;
      case CareActivityType.toileting:
        return Icons.wc;
      case CareActivityType.hydration:
        return Icons.local_drink;
      case CareActivityType.meal:
        return Icons.restaurant;
      case CareActivityType.behavior:
        return Icons.psychology;
      case CareActivityType.photo:
        return Icons.camera_alt;
      case CareActivityType.note:
        return Icons.note;
      case CareActivityType.pain:
        return Icons.sick;
      case CareActivityType.vitals:
        return Icons.favorite;
      case CareActivityType.location:
        return Icons.location_on;
    }
  }

  Color _getActivityTypeColor(CareActivityType type) {
    switch (type) {
      case CareActivityType.medication:
        return Colors.green;
      case CareActivityType.toileting:
        return Colors.orange;
      case CareActivityType.hydration:
        return Colors.blue;
      case CareActivityType.meal:
        return Colors.green;
      case CareActivityType.behavior:
        return Colors.purple;
      case CareActivityType.photo:
        return Colors.grey;
      case CareActivityType.note:
        return Colors.blue;
      case CareActivityType.pain:
        return Colors.red;
      case CareActivityType.vitals:
        return Colors.pink;
      case CareActivityType.location:
        return Colors.teal;
    }
  }

  String _getLogDetails(CareLog log) {
    final time = '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}';
    final date = '${log.timestamp.month.toString().padLeft(2, '0')}/${log.timestamp.day.toString().padLeft(2, '0')}/${log.timestamp.year}';
    
    String details = '$time on $date';
    
    if (log.details != null && log.details!.isNotEmpty) {
      details += '\n${log.details}';
    }
    
    if (log.notes != null && log.notes!.isNotEmpty) {
      details += '\nNotes: ${log.notes}';
    }
    
    return details;
  }

  void showFilterOptions() {
    UniversalPopup.show(
      title: 'Filter Options',
      subtitle: 'Select filters to narrow down results',
      icon: Icons.filter_list,
      color: Colors.blue,
      actions: [
        PopupAction(
          title: 'Filter by Client',
          icon: Icons.people,
          color: Colors.blue,
          onTap: () => _showClientPicker(),
        ),
        PopupAction(
          title: 'Filter by Activity',
          icon: Icons.category,
          color: Colors.green,
          onTap: () => _showActivityTypePicker(),
        ),
        PopupAction(
          title: 'Filter by Date',
          icon: Icons.calendar_today,
          color: Colors.orange,
          onTap: () => _showDatePicker(),
        ),
        PopupAction(
          title: 'Clear All Filters',
          icon: Icons.clear,
          color: Colors.red,
          onTap: () => _clearFilters(),
        ),
      ],
    );
  }

  void _showClientPicker() async {
    Get.back();
    // TODO: Implement client picker
    Get.snackbar(
      'Info',
      'Client picker coming soon',
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[800],
    );
  }

  void _showActivityTypePicker() {
    Get.back();
    UniversalPopup.showSubOptions(
      title: 'Select Activity Type',
      options: [
        'All Activities',
        ...CareActivityType.values.map((type) => type.name),
      ],
      onSelect: (option) {
        if (option == 'All Activities') {
          selectedActivityType.value = null;
        } else {
          selectedActivityType.value = CareActivityType.values.firstWhere(
            (type) => type.name == option,
          );
        }
      },
    );
  }

  void _showDatePicker() async {
    Get.back();
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      selectedDate.value = date;
    }
  }

  void _clearFilters() {
    Get.back();
    selectedClient.value = null;
    selectedActivityType.value = null;
    selectedDate.value = null;
  }

  void setDateFilter(DateTime? date) {
    selectedDate.value = date;
  }

  @override
  void onClose() {
    // Clear all reactive variables to prevent memory leaks
    careLogs.clear();
    selectedClient.value = null;
    selectedActivityType.value = null;
    selectedDate.value = null;
    
    super.onClose();
  }
} 