import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class FacilityHistoryView extends GetView<HomeController> {
  const FacilityHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Facility History'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[600]),
          onPressed: () => Get.back(),
        ),
        actions: [
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
              }
            },
            itemBuilder: (context) => [
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // Filter section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: DropdownButton<String>(
                        value: 'all',
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('All Activities')),
                          const DropdownMenuItem(value: 'clock_in_out', child: Text('Clock In/Out')),
                          const DropdownMenuItem(value: 'break', child: Text('Breaks')),
                          const DropdownMenuItem(value: 'house_note', child: Text('House Notes')),
                          const DropdownMenuItem(value: 'supplies', child: Text('Supplies')),
                          const DropdownMenuItem(value: 'complaint', child: Text('Complaints')),
                          const DropdownMenuItem(value: 'checklist', child: Text('Checklist')),
                        ],
                        onChanged: (value) {
                          // TODO: Implement filtering
                          Get.snackbar('Info', 'Filtering coming soon');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Logs list
            Expanded(
              child: Obx(() {
                final logs = controller.getRecentLogs();
                
                if (logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No activity logs yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start using the facility features to see logs here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
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
                            color: _getLogTypeColor(log.type).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getLogTypeIcon(log.type),
                            color: _getLogTypeColor(log.type),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          log.action,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
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
                            Text(
                              _formatDateTime(log.timestamp),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getLogTypeColor(log.type).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getLogTypeLabel(log.type),
                                style: TextStyle(
                                  color: _getLogTypeColor(log.type),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _showEditLogDialog(log);
                                    break;
                                  case 'delete':
                                    _showDeleteLogDialog(log);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 16, color: Colors.blue[600]),
                                      const SizedBox(width: 8),
                                      const Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 16, color: Colors.red[600]),
                                      const SizedBox(width: 8),
                                      const Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLogTypeColor(String type) {
    switch (type) {
      case 'clock_in_out':
        return Colors.blue;
      case 'break':
        return Colors.orange;
      case 'house_note':
        return Colors.green;
      case 'supplies':
        return Colors.purple;
      case 'complaint':
        return Colors.red;
      case 'checklist':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getLogTypeIcon(String type) {
    switch (type) {
      case 'clock_in_out':
        return Icons.access_time;
      case 'break':
        return Icons.coffee;
      case 'house_note':
        return Icons.note;
      case 'supplies':
        return Icons.inventory;
      case 'complaint':
        return Icons.report_problem;
      case 'checklist':
        return Icons.checklist;
      default:
        return Icons.info;
    }
  }

  String _getLogTypeLabel(String type) {
    switch (type) {
      case 'clock_in_out':
        return 'Clock';
      case 'break':
        return 'Break';
      case 'house_note':
        return 'Note';
      case 'supplies':
        return 'Supplies';
      case 'complaint':
        return 'Complaint';
      case 'checklist':
        return 'Checklist';
      default:
        return 'Other';
    }
  }

  String _formatDateTime(DateTime dateTime) {
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

  void _showEditLogDialog(FacilityLog log) {
    final TextEditingController descriptionController = TextEditingController(text: log.description);
    
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
                // Edit icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Edit Log Entry',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Description field
                Container(
                  width: double.infinity,
                  child: TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Edit description...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement edit functionality
                            Get.snackbar(
                              'Log Updated',
                              'Log entry has been updated',
                              backgroundColor: Colors.green[100],
                              colorText: Colors.green[800],
                            );
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Update',
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

  void _showDeleteLogDialog(FacilityLog log) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Delete Log Entry',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                'Are you sure you want to delete this log entry? This action cannot be undone.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement delete functionality
                          Get.snackbar(
                            'Log Deleted',
                            'Log entry has been deleted',
                            backgroundColor: Colors.orange[100],
                            colorText: Colors.orange[800],
                          );
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearLogsDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Clear All Logs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                'Are you sure you want to clear all facility activity logs? This action cannot be undone.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          controller.clearAllLogs();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Clear All',
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
    );
  }
} 