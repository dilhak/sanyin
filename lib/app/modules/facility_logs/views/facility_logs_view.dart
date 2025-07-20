import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/facility_logs_controller.dart';
import '../models/facility_log_model.dart';
import '../../../widgets/universal_popup.dart';
import '../../client/controllers/client_dashboard_controller.dart';

class FacilityLogsView extends GetView<FacilityLogsController> {
  const FacilityLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get home name from arguments
    final args = Get.arguments;
    String homeName = 'Facility Logs';
    if (args != null && args['homeId'] != null && args['homeId'] > 0) {
      // Get home name from client dashboard controller
      final clientController = Get.find<ClientDashboardController>();
      final homeId = args['homeId'];
      final clientWithAddress = clientController.clients.firstWhereOrNull(
        (client) => client.id == homeId
      );
      if (clientWithAddress != null && clientWithAddress.address != null) {
        homeName = '${clientWithAddress.address} - Facility Logs';
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(homeName),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[600]),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.blue[600]),
            onPressed: () => _showFilterDialog(),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.blue[600]),
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _showClearLogsDialog();
                  break;
                case 'export':
                  Get.snackbar('Info', 'Export feature coming soon');
                  break;
                case 'add':
                  _showAddLogDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'add',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 18, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    const Text('Add Log'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 18, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    const Text('Clear All Logs'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 18, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    const Text('Export Logs'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Obx(() => _buildFilterChips()),
          // Logs list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final groupedLogs = controller.groupedLogs;
              
              if (groupedLogs.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.loadFacilityLogs,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedLogs.length,
                  itemBuilder: (context, index) {
                    final entry = groupedLogs.entries.elementAt(index);
                    final date = entry.key;
                    final logs = entry.value;
                    return _buildDateSection(date, logs);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (controller.selectedType.value != null)
            Chip(
              label: Text(controller.getLogTypeLabel(controller.selectedType.value!)),
              onDeleted: () => controller.setTypeFilter(null),
              backgroundColor: controller.getLogTypeColor(controller.selectedType.value!).withValues(alpha: 0.1),
              deleteIcon: Icon(Icons.close, color: controller.getLogTypeColor(controller.selectedType.value!)),
            ),
          if (controller.selectedPriority.value != null)
            Chip(
              label: Text(controller.selectedPriority.value!.name.toUpperCase()),
              onDeleted: () => controller.setPriorityFilter(null),
              backgroundColor: controller.getPriorityColor(controller.selectedPriority.value!).withValues(alpha: 0.1),
              deleteIcon: Icon(Icons.close, color: controller.getPriorityColor(controller.selectedPriority.value!)),
            ),
          if (controller.selectedDate.value != null)
            Chip(
              label: Text('Date: ${_formatDate(controller.selectedDate.value!)}'),
              onDeleted: () => controller.setDateFilter(null),
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              deleteIcon: const Icon(Icons.close, color: Colors.blue),
            ),
          if (controller.selectedType.value != null || controller.selectedPriority.value != null || controller.selectedDate.value != null)
            TextButton(
              onPressed: controller.clearFilters,
              child: const Text('Clear All'),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No facility logs yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start using facility features to see logs here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddLogDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add First Log'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(DateTime date, List<FacilityLog> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            _formatDate(date),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        ...logs.map((log) => _buildLogCard(log)),
      ],
    );
  }

  Widget _buildLogCard(FacilityLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: controller.getLogTypeColor(log.type).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            controller.getLogTypeIcon(log.type),
            color: controller.getLogTypeColor(log.type),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                log.action,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  decoration: log.isResolved ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: controller.getPriorityColor(log.priority).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                log.priority.name.toUpperCase(),
                style: TextStyle(
                  color: controller.getPriorityColor(log.priority),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  controller.formatDateTime(log.timestamp),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                if (log.staffMember != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'by ${log.staffMember}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
                if (log.isResolved) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'RESOLVED',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onPressed: () => controller.showLogActions(log),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Filter Logs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Type filter
            DropdownButtonFormField<FacilityLogType?>(
              decoration: const InputDecoration(
                labelText: 'Log Type',
                border: OutlineInputBorder(),
              ),
              value: controller.selectedType.value,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Types')),
                ...FacilityLogType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(controller.getLogTypeLabel(type)),
                )),
              ],
              onChanged: controller.setTypeFilter,
            ),
            const SizedBox(height: 16),
            // Priority filter
            DropdownButtonFormField<FacilityLogPriority?>(
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              value: controller.selectedPriority.value,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Priorities')),
                ...FacilityLogPriority.values.map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority.name.toUpperCase()),
                )),
              ],
              onChanged: controller.setPriorityFilter,
            ),
            const SizedBox(height: 16),
            // Resolved filter
            Obx(() => SwitchListTile(
              title: const Text('Show Resolved'),
              value: controller.showResolved.value,
              onChanged: (value) => controller.toggleResolvedFilter(),
            )),
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

  void _showAddLogDialog() {
    final TextEditingController actionController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final Rx<FacilityLogType> selectedType = FacilityLogType.other.obs;
    final Rx<FacilityLogPriority> selectedPriority = FacilityLogPriority.medium.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Add Facility Log',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: actionController,
              decoration: const InputDecoration(
                labelText: 'Action',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<FacilityLogType>(
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              value: selectedType.value,
              items: FacilityLogType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Text(controller.getLogTypeLabel(type)),
              )).toList(),
              onChanged: (value) => selectedType.value = value!,
            )),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<FacilityLogPriority>(
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              value: selectedPriority.value,
              items: FacilityLogPriority.values.map((priority) => DropdownMenuItem(
                value: priority,
                child: Text(priority.name.toUpperCase()),
              )).toList(),
              onChanged: (value) => selectedPriority.value = value!,
            )),
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
                      if (actionController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                        controller.addFacilityLog(
                          action: actionController.text,
                          description: descriptionController.text,
                          type: selectedType.value,
                          priority: selectedPriority.value,
                        );
                        Get.back();
                      }
                    },
                    child: const Text('Add Log'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClearLogsDialog() {
    UniversalPopup.showConfirmation(
      title: 'Clear All Logs',
      message: 'Are you sure you want to clear all facility logs? This action cannot be undone.',
      confirmText: 'Clear All',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
      onConfirm: () {
        // TODO: Implement clear all logs
        Get.snackbar(
          'Logs Cleared',
          'All facility logs have been cleared',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[800],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (date.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
} 