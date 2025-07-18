import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/care_log_model.dart';
import '../../../services/database_service.dart';
import '../../client/models/client_model.dart';

class CareLogHistoryController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
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
      Get.snackbar(
        'Error',
        'Failed to load care logs: $e',
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

  void showFilterOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildFilterSection(
              'Client',
              selectedClient.value?.name ?? 'All Clients',
              () => _showClientPicker(),
            ),
            const SizedBox(height: 16),
            _buildFilterSection(
              'Activity Type',
              selectedActivityType.value?.name ?? 'All Activities',
              () => _showActivityTypePicker(),
            ),
            const SizedBox(height: 16),
            _buildFilterSection(
              'Date',
              selectedDate.value != null 
                ? '${selectedDate.value!.day}/${selectedDate.value!.month}/${selectedDate.value!.year}'
                : 'All Dates',
              () => _showDatePicker(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear Filters'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  void _showClientPicker() async {
    // TODO: Implement client picker
    Get.back();
  }

  void _showActivityTypePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Activity Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...CareActivityType.values.map((type) => ListTile(
              title: Text(type.name),
              onTap: () {
                selectedActivityType.value = type;
                Get.back();
              },
            )),
            ListTile(
              title: const Text('All Activities'),
              onTap: () {
                selectedActivityType.value = null;
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
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
    selectedClient.value = null;
    selectedActivityType.value = null;
    selectedDate.value = null;
  }
} 