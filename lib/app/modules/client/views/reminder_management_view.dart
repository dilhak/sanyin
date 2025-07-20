import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/client_details_controller.dart';
import '../../../models/reminder_model.dart';
import '../../../services/notification_service.dart';

class ReminderManagementView extends GetView<ClientDetailsController> {
  const ReminderManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Reminders for ${controller.client.name}'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[600]),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => Column(
        children: [
          // Header with stats
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${controller.reminders.length}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        Text(
                          'Total Reminders',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${controller.reminders.where((r) => r.isActive).length}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Reminders list
          if (controller.reminders.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.reminders.length,
                itemBuilder: (context, index) {
                  final reminder = controller.reminders[index];
                  return _buildReminderCard(reminder);
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reminders set',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add your first reminder',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      )),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              try {
                final notificationService = NotificationService();
                await notificationService.checkNotificationSettings();
                Get.snackbar(
                  'Info',
                  'Check console for notification settings details',
                  backgroundColor: Colors.blue[100],
                  colorText: Colors.blue[800],
                  duration: const Duration(seconds: 3),
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to check settings: $e',
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[800],
                  duration: const Duration(seconds: 5),
                );
              }
            },
            backgroundColor: Colors.purple[600],
            heroTag: 'check_settings',
            child: const Icon(Icons.settings, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () async {
              try {
                final notificationService = NotificationService();
                
                // Check if notifications are enabled
                final enabled = await notificationService.areNotificationsEnabled();
                if (!enabled) {
                  Get.snackbar(
                    'Warning',
                    'Notifications are not enabled. Please enable them in device settings.',
                    backgroundColor: Colors.orange[100],
                    colorText: Colors.orange[800],
                    duration: const Duration(seconds: 5),
                  );
                  return;
                }
                
                await notificationService.showTestNotification();
                Get.snackbar(
                  'Success',
                  'Test notification sent! Check your notification panel.',
                  backgroundColor: Colors.green[100],
                  colorText: Colors.green[800],
                  duration: const Duration(seconds: 3),
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to send test notification: $e',
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[800],
                  duration: const Duration(seconds: 5),
                );
              }
            },
            backgroundColor: Colors.orange[600],
            heroTag: 'test_notification',
            child: const Icon(Icons.notifications, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => controller.showAddReminderDialog(),
            backgroundColor: Colors.blue[600],
            heroTag: 'add_reminder',
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final isActive = reminder.isActive;
    final timeString = _formatTime(reminder.scheduledTime);
    final dateString = _formatDate(reminder.scheduledTime);
    final isOverdue = reminder.scheduledTime.isBefore(DateTime.now()) && isActive;

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
        border: isOverdue ? Border.all(color: Colors.red[300]!, width: 1) : null,
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isOverdue 
                    ? Colors.red.withValues(alpha: 0.1)
                    : isActive 
                        ? Colors.blue.withValues(alpha: 0.1) 
                        : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOverdue 
                    ? Icons.warning
                    : isActive 
                        ? Icons.notifications_active 
                        : Icons.notifications_off,
                color: isOverdue 
                    ? Colors.red[600]
                    : isActive 
                        ? Colors.blue[600] 
                        : Colors.grey[600],
                size: 24,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    reminder.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'OVERDUE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  reminder.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isOverdue ? Colors.red[500] : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$timeString on $dateString',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? Colors.red[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),

          ),
          // Quick action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => controller.editReminder(reminder),
                    icon: Icon(Icons.edit, size: 16, color: Colors.blue[600]),
                    label: Text(
                      'Edit',
                      style: TextStyle(color: Colors.blue[600], fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => controller.toggleReminder(reminder),
                    icon: Icon(
                      isActive ? Icons.notifications_off : Icons.notifications_active,
                      size: 16,
                      color: isActive ? Colors.orange[600] : Colors.green[600],
                    ),
                    label: Text(
                      isActive ? 'Disable' : 'Enable',
                      style: TextStyle(
                        color: isActive ? Colors.orange[600] : Colors.green[600],
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => controller.deleteReminder(reminder),
                    icon: Icon(Icons.delete, size: 16, color: Colors.red[600]),
                    label: Text(
                      'Delete',
                      style: TextStyle(color: Colors.red[600], fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final reminderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (reminderDate == today) {
      return 'Today';
    } else if (reminderDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }
} 