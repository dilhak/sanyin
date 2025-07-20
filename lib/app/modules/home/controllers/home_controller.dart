import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import '../../../services/database_service.dart';
import '../../../models/facility_log_model.dart';

class HomeController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();

  // Clock In/Out
  final isOnShift = false.obs;
  final clockInTime = Rx<DateTime?>(null);
  final clockOutTime = Rx<DateTime?>(null);

  // Break Management
  final isOnBreak = false.obs;
  final breakStartTime = Rx<DateTime?>(null);
  final breakTimer = Rx<Duration>(Duration.zero);
  final breakReason = ''.obs;
  Timer? breakTimerController;

  // House Note
  final houseNote = ''.obs;
  final houseNotePhoto = Rx<String?>(null);

  // Supplies
  final selectedSupplyItem = ''.obs;
  final supplyStatus = 'OK'.obs;
  final supplyPhoto = Rx<String?>(null);

  // Complaint/Concern
  final complaintDescription = ''.obs;
  final complaintType = 'Environmental'.obs;
  final complaintPhoto = Rx<String?>(null);

  // Shift Checklist
  final checklistItems = <String, bool>{}.obs;
  final customChecklistItems = <String>[].obs;

  // Facility History Logs
  final facilityLogs = <FacilityLog>[].obs;

  final supplyItems = [
    'Cleaning Supplies',
    'Medical Supplies',
    'Food & Beverages',
    'Personal Care Items',
    'Safety Equipment',
    'Office Supplies',
  ];

  final complaintTypes = [
    'Environmental',
    'Staff',
    'Family',
    'Other',
  ];

  final defaultChecklistItems = [
    'Trash emptied',
    'Bathrooms checked',
    'Lights off',
    'Clients stable',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeChecklist();
    // Load facility logs after a short delay to ensure database is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadFacilityLogs();
    });
  }

  void _initializeChecklist() {
    for (String item in defaultChecklistItems) {
      checklistItems[item] = false;
    }
  }

  void _loadFacilityLogs() async {
    try {
      final logs = await _databaseService.getFacilityLogs();
      facilityLogs.assignAll(logs);
    } catch (e) {
      print('Failed to load facility logs: $e');
      // Don't show error to user on app startup, just log it
    }
  }

  // Logging Methods
  void _addLog(String action, String description, String type, {Map<String, dynamic>? additionalData}) async {
    final log = FacilityLog(
      action: action,
      description: description,
      timestamp: DateTime.now(),
      type: type,
      additionalData: additionalData != null ? jsonEncode(additionalData) : null,
    );
    
    try {
      await _databaseService.insertFacilityLog(log);
      facilityLogs.add(log);
      print('Facility Log: $action - $description at ${_formatDateTime(DateTime.now())}');
    } catch (e) {
      print('Failed to save facility log: $e');
      Get.snackbar(
        'Error',
        'Failed to save log to database',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  // Clock In/Out Methods
  void toggleClockInOut() {
    if (isOnShift.value) {
      _clockOut();
    } else {
      _clockIn();
    }
  }

  void _clockIn() {
    isOnShift.value = true;
    clockInTime.value = DateTime.now();
    clockOutTime.value = null;
    _addLog(
      'Clock In',
      'Successfully clocked in at ${_formatTime(DateTime.now())}',
      'clock_in_out',
      additionalData: {'time': _formatTime(DateTime.now())},
    );
    Get.snackbar(
      'Clock In',
      'Successfully clocked in at ${_formatTime(DateTime.now())}',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
    );
  }

  void _clockOut() {
    isOnShift.value = false;
    clockOutTime.value = DateTime.now();
    _addLog(
      'Clock Out',
      'Successfully clocked out at ${_formatTime(DateTime.now())}',
      'clock_in_out',
      additionalData: {'time': _formatTime(DateTime.now())},
    );
    Get.snackbar(
      'Clock Out',
      'Successfully clocked out at ${_formatTime(DateTime.now())}',
      backgroundColor: Colors.orange[100],
      colorText: Colors.orange[800],
    );
  }

  // Break Methods
  void toggleBreak() {
    if (isOnBreak.value) {
      _endBreak();
    } else {
      _startBreak();
    }
  }

  void _startBreak() {
    isOnBreak.value = true;
    breakStartTime.value = DateTime.now();
    breakTimer.value = Duration.zero;
    _startBreakTimer();
    _addLog(
      'Break Started',
      'Break started at ${_formatTime(DateTime.now())}',
      'break',
      additionalData: {
        'time': _formatTime(DateTime.now()),
        'reason': breakReason.value.isNotEmpty ? breakReason.value : 'Not specified',
      },
    );
    Get.snackbar(
      'Break Started',
      'Break started at ${_formatTime(DateTime.now())}',
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[800],
    );
  }

  void _endBreak() {
    final breakDuration = breakTimer.value;
    isOnBreak.value = false;
    breakStartTime.value = null;
    breakTimer.value = Duration.zero;
    _stopBreakTimer();
    _addLog(
      'Break Ended',
      'Break ended. Total break time: ${_formatDuration(breakDuration)}',
      'break',
      additionalData: {
        'duration': _formatDuration(breakDuration),
        'reason': breakReason.value.isNotEmpty ? breakReason.value : 'Not specified',
      },
    );
    Get.snackbar(
      'Break Ended',
      'Break ended. Total break time: ${_formatDuration(breakDuration)}',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
    );
  }

  void _startBreakTimer() {
    breakTimerController = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isOnBreak.value && breakStartTime.value != null) {
        breakTimer.value = DateTime.now().difference(breakStartTime.value!);
      }
    });
  }

  void _stopBreakTimer() {
    breakTimerController?.cancel();
  }

  void setBreakReason(String reason) {
    breakReason.value = reason;
  }

  // House Note Methods
  void setHouseNote(String note) {
    houseNote.value = note;
  }

  void addHouseNote() {
    if (houseNote.value.isNotEmpty) {
      _addLog(
        'House Note Added',
        houseNote.value,
        'house_note',
        additionalData: {
          'note': houseNote.value,
          'time': _formatTime(DateTime.now()),
        },
      );
      Get.snackbar(
        'House Note Added',
        'Note logged at ${_formatTime(DateTime.now())}',
        backgroundColor: Colors.blue[100],
        colorText: Colors.blue[800],
      );
      houseNote.value = '';
    }
  }

  // Supplies Methods
  void setSupplyItem(String item) {
    selectedSupplyItem.value = item;
  }

  void setSupplyStatus(String status) {
    supplyStatus.value = status;
  }

  void updateSupplies() {
    if (selectedSupplyItem.value.isNotEmpty) {
      _addLog(
        'Supplies Updated',
        '${selectedSupplyItem.value} status updated to ${supplyStatus.value}',
        'supplies',
        additionalData: {
          'item': selectedSupplyItem.value,
          'status': supplyStatus.value,
          'time': _formatTime(DateTime.now()),
        },
      );
      Get.snackbar(
        'Supplies Updated',
        '${selectedSupplyItem.value} status: ${supplyStatus.value}',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
    }
  }

  // Complaint Methods
  void setComplaintDescription(String description) {
    complaintDescription.value = description;
  }

  void setComplaintType(String type) {
    complaintType.value = type;
  }

  void submitComplaint() {
    if (complaintDescription.value.isNotEmpty) {
      _addLog(
        'Complaint Submitted',
        complaintDescription.value,
        'complaint',
        additionalData: {
          'type': complaintType.value,
          'description': complaintDescription.value,
          'time': _formatTime(DateTime.now()),
        },
      );
      Get.snackbar(
        'Complaint Submitted',
        'Complaint logged at ${_formatTime(DateTime.now())}',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );
      complaintDescription.value = '';
    }
  }

  // Checklist Methods
  void toggleChecklistItem(String item) {
    if (checklistItems.containsKey(item)) {
      final newStatus = !checklistItems[item]!;
      checklistItems[item] = newStatus;
      _addLog(
        'Checklist Item Updated',
        '$item marked as ${newStatus ? "completed" : "incomplete"}',
        'checklist',
        additionalData: {
          'item': item,
          'status': newStatus,
          'time': _formatTime(DateTime.now()),
        },
      );
    }
  }

  void addCustomChecklistItem(String item) {
    if (item.isNotEmpty && !checklistItems.containsKey(item)) {
      checklistItems[item] = false;
      customChecklistItems.add(item);
      _addLog(
        'Custom Checklist Item Added',
        'Added new item: $item',
        'checklist',
        additionalData: {
          'item': item,
          'time': _formatTime(DateTime.now()),
        },
      );
    }
  }

  void removeCustomChecklistItem(String item) {
    checklistItems.remove(item);
    customChecklistItems.remove(item);
  }

  // Utility Methods
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
  }

  // Facility History Methods
  void viewFacilityHistory() {
    Get.toNamed('/facility/history');
  }

  List<FacilityLog> getLogsByType(String type) {
    return facilityLogs.where((log) => log.type == type).toList();
  }

  List<FacilityLog> getRecentLogs({int limit = 50}) {
    final sortedLogs = List<FacilityLog>.from(facilityLogs);
    sortedLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedLogs.take(limit).toList();
  }

  void clearAllLogs() async {
    try {
      await _databaseService.clearAllFacilityLogs();
      facilityLogs.clear();
      Get.snackbar(
        'Logs Cleared',
        'All facility logs have been cleared',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );
    } catch (e) {
      print('Failed to clear facility logs: $e');
      Get.snackbar(
        'Error',
        'Failed to clear logs from database',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  String getCurrentStatus() {
    if (isOnShift.value) {
      return 'On Shift';
    } else {
      return 'Off Shift';
    }
  }

  String getBreakStatus() {
    if (isOnBreak.value) {
      return 'On Break - ${_formatDuration(breakTimer.value)}';
    } else {
      return 'Not on break';
    }
  }

  @override
  void onClose() {
    _stopBreakTimer();
    super.onClose();
  }
}
