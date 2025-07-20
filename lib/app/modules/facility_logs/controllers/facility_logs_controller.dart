import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/facility_log_model.dart';
import '../../../services/database_service.dart';
import '../../../core/error_handler.dart';
import '../../../widgets/universal_popup.dart';

class FacilityLogsController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final ErrorHandler _errorHandler = ErrorHandler();
  
  final RxList<FacilityLog> facilityLogs = <FacilityLog>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<FacilityLogType?> selectedType = Rx<FacilityLogType?>(null);
  final Rx<FacilityLogPriority?> selectedPriority = Rx<FacilityLogPriority?>(null);
  final RxBool showResolved = false.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxInt currentHomeId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Get homeId from arguments
    final args = Get.arguments;
    if (args != null && args['homeId'] != null) {
      currentHomeId.value = args['homeId'];
    }
    loadFacilityLogs();
  }

  Future<void> loadFacilityLogs() async {
    isLoading.value = true;
    try {
      if (currentHomeId.value > 0) {
        final logs = await _databaseService.getFacilityLogsForHome(currentHomeId.value);
        facilityLogs.value = logs;
      } else {
        // If no specific home is selected, show all logs (including those with homeId = 0)
        final logs = await _databaseService.getAllFacilityLogs();
        facilityLogs.value = logs;
      }
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    } finally {
      isLoading.value = false;
    }
  }

  List<FacilityLog> get filteredLogs {
    List<FacilityLog> filtered = facilityLogs;

    // Filter by type
    if (selectedType.value != null) {
      filtered = filtered.where((log) => log.type == selectedType.value).toList();
    }

    // Filter by priority
    if (selectedPriority.value != null) {
      filtered = filtered.where((log) => log.priority == selectedPriority.value).toList();
    }

    // Filter by resolved status
    if (!showResolved.value) {
      filtered = filtered.where((log) => !log.isResolved).toList();
    }

    // Filter by date
    if (selectedDate.value != null) {
      final selectedDay = selectedDate.value!;
      filtered = filtered.where((log) {
        final logDay = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
        return logDay.isAtSameMomentAs(selectedDay);
      }).toList();
    }

    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
  }

  Map<DateTime, List<FacilityLog>> get groupedLogs {
    final grouped = <DateTime, List<FacilityLog>>{};
    
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
    final sortedMap = <DateTime, List<FacilityLog>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    
    return sortedMap;
  }

  Future<void> addFacilityLog({
    required String action,
    required String description,
    required FacilityLogType type,
    FacilityLogPriority priority = FacilityLogPriority.medium,
    String? staffMember,
    String? location,
    Map<String, dynamic>? additionalData,
    String? photoPath,
  }) async {
    try {
      final log = FacilityLog(
        homeId: currentHomeId.value,
        action: action,
        description: description,
        timestamp: DateTime.now(),
        type: type,
        priority: priority,
        staffMember: staffMember,
        location: location,
        additionalData: additionalData,
        photoPath: photoPath,
      );

      await _databaseService.insertFacilityLog(log);
      await loadFacilityLogs();
      
      _errorHandler.showSuccessSnackbar('Facility log added successfully');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  Future<void> updateFacilityLog(FacilityLog log, {
    String? action,
    String? description,
    FacilityLogType? type,
    FacilityLogPriority? priority,
    String? staffMember,
    String? location,
    Map<String, dynamic>? additionalData,
    String? photoPath,
  }) async {
    try {
      final updatedLog = log.copyWith(
        action: action,
        description: description,
        type: type,
        priority: priority,
        staffMember: staffMember,
        location: location,
        additionalData: additionalData,
        photoPath: photoPath,
      );

      await _databaseService.updateFacilityLog(updatedLog);
      await loadFacilityLogs();
      
      _errorHandler.showSuccessSnackbar('Facility log updated successfully');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  Future<void> resolveFacilityLog(FacilityLog log, String resolvedBy) async {
    try {
      final resolvedLog = log.copyWith(
        isResolved: true,
        resolvedAt: DateTime.now(),
        resolvedBy: resolvedBy,
      );

      await _databaseService.updateFacilityLog(resolvedLog);
      await loadFacilityLogs();
      
      _errorHandler.showSuccessSnackbar('Facility log marked as resolved');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  Future<void> deleteFacilityLog(FacilityLog log) async {
    try {
      await _databaseService.deleteFacilityLog(log.id!);
      await loadFacilityLogs();
      
      _errorHandler.showSuccessSnackbar('Facility log deleted successfully');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  void showLogActions(FacilityLog log) {
    UniversalPopup.show(
      title: log.action,
      subtitle: log.description,
      icon: getLogTypeIcon(log.type),
      color: getLogTypeColor(log.type),
      actions: [
        PopupAction(
          title: 'Edit',
          icon: Icons.edit,
          color: Colors.blue,
          onTap: () => _editLog(log),
        ),
        if (!log.isResolved)
          PopupAction(
            title: 'Resolve',
            icon: Icons.check_circle,
            color: Colors.green,
            onTap: () => _resolveLog(log),
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

  void _editLog(FacilityLog log) {
    Get.back();
    UniversalPopup.showInputDialog(
      title: 'Edit Facility Log',
      hintText: 'Enter updated description...',
      maxLines: 3,
      onConfirm: (description) {
        updateFacilityLog(log, description: description);
      },
    );
  }

  void _resolveLog(FacilityLog log) {
    Get.back();
    UniversalPopup.showInputDialog(
      title: 'Resolve Log',
      hintText: 'Enter resolution notes...',
      maxLines: 2,
      onConfirm: (notes) {
        resolveFacilityLog(log, 'Current User'); // TODO: Get actual user
      },
    );
  }

  void _deleteLog(FacilityLog log) {
    Get.back();
    UniversalPopup.showConfirmation(
      title: 'Delete Log',
      message: 'Are you sure you want to delete this facility log? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
      onConfirm: () => deleteFacilityLog(log),
    );
  }

  void clearFilters() {
    selectedType.value = null;
    selectedPriority.value = null;
    showResolved.value = false;
    selectedDate.value = null;
  }

  void setTypeFilter(FacilityLogType? type) {
    selectedType.value = type;
  }

  void setPriorityFilter(FacilityLogPriority? priority) {
    selectedPriority.value = priority;
  }

  void toggleResolvedFilter() {
    showResolved.value = !showResolved.value;
  }

  void setDateFilter(DateTime? date) {
    selectedDate.value = date;
  }

  Color getLogTypeColor(FacilityLogType type) {
    switch (type) {
      case FacilityLogType.clockInOut:
        return Colors.blue;
      case FacilityLogType.breakTime:
        return Colors.orange;
      case FacilityLogType.houseNote:
        return Colors.green;
      case FacilityLogType.supplies:
        return Colors.purple;
      case FacilityLogType.complaint:
        return Colors.red;
      case FacilityLogType.checklist:
        return Colors.teal;
      case FacilityLogType.maintenance:
        return Colors.indigo;
      case FacilityLogType.incident:
        return Colors.red;
      case FacilityLogType.visitor:
        return Colors.amber;
      case FacilityLogType.medication:
        return Colors.green;
      case FacilityLogType.emergency:
        return Colors.red;
      case FacilityLogType.other:
        return Colors.grey;
    }
  }

  IconData getLogTypeIcon(FacilityLogType type) {
    switch (type) {
      case FacilityLogType.clockInOut:
        return Icons.access_time;
      case FacilityLogType.breakTime:
        return Icons.coffee;
      case FacilityLogType.houseNote:
        return Icons.note;
      case FacilityLogType.supplies:
        return Icons.inventory;
      case FacilityLogType.complaint:
        return Icons.report_problem;
      case FacilityLogType.checklist:
        return Icons.checklist;
      case FacilityLogType.maintenance:
        return Icons.build;
      case FacilityLogType.incident:
        return Icons.warning;
      case FacilityLogType.visitor:
        return Icons.people;
      case FacilityLogType.medication:
        return Icons.medication;
      case FacilityLogType.emergency:
        return Icons.emergency;
      case FacilityLogType.other:
        return Icons.info;
    }
  }

  String getLogTypeLabel(FacilityLogType type) {
    switch (type) {
      case FacilityLogType.clockInOut:
        return 'Clock';
      case FacilityLogType.breakTime:
        return 'Break';
      case FacilityLogType.houseNote:
        return 'Note';
      case FacilityLogType.supplies:
        return 'Supplies';
      case FacilityLogType.complaint:
        return 'Complaint';
      case FacilityLogType.checklist:
        return 'Checklist';
      case FacilityLogType.maintenance:
        return 'Maintenance';
      case FacilityLogType.incident:
        return 'Incident';
      case FacilityLogType.visitor:
        return 'Visitor';
      case FacilityLogType.medication:
        return 'Medication';
      case FacilityLogType.emergency:
        return 'Emergency';
      case FacilityLogType.other:
        return 'Other';
    }
  }

  Color getPriorityColor(FacilityLogPriority priority) {
    switch (priority) {
      case FacilityLogPriority.low:
        return Colors.green;
      case FacilityLogPriority.medium:
        return Colors.orange;
      case FacilityLogPriority.high:
        return Colors.red;
      case FacilityLogPriority.critical:
        return Colors.purple;
    }
  }

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (logDate == today) {
      return 'Today at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (logDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
} 