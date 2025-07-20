import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/care_log_history_controller.dart';
import '../models/care_log_model.dart';

class CareLogHistoryView extends GetView<CareLogHistoryController> {
  const CareLogHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Diary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.careLogs.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.loadCareLogs,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(20),
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 24),
              ...controller.groupedLogs.entries.map((entry) {
                final date = entry.key;
                final logs = entry.value;
                return _buildDateSection(date, logs);
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      children: [
        // Date card
        Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getDayOfWeek(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                DateTime.now().day.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                controller.careLogs.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Title section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Activity Diary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Complete care history',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 60,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Care Logs Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Care activities will appear here once logged',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Text(
              'Start logging care activities to see them here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(DateTime date, List<CareLog> logs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Text(
            _formatDate(date),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...logs.map((log) => _buildLogCard(log)),
        ],
      ),
    );
  }



  Widget _buildLogCard(CareLog log) {
    final activityColor = _getActivityColor(log.activityType);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.showLogActions(log),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Activity icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: activityColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getActivityIcon(log.activityType),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and time
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getActivityTypeTitle(log.activityType).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(log.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // Description (details without activity type prefix)
                      if (log.details != null && log.details!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _getCleanDescription(log.details!, log.activityType),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Color _getActivityColor(CareActivityType activityType) {
    switch (activityType) {
      case CareActivityType.medication:
        return Colors.red[600]!;
      case CareActivityType.toileting:
        return Colors.orange[600]!;
      case CareActivityType.hydration:
        return Colors.blue[600]!;
      case CareActivityType.meal:
        return Colors.green[600]!;
      case CareActivityType.behavior:
        return Colors.purple[600]!;
      case CareActivityType.photo:
        return Colors.teal[600]!;
      case CareActivityType.note:
        return Colors.indigo[600]!;
      case CareActivityType.pain:
        return Colors.red[600]!;
      case CareActivityType.vitals:
        return Colors.pink[600]!;
      case CareActivityType.location:
        return Colors.teal[600]!;
    }
  }

  String _getActivityTypeTitle(CareActivityType activityType) {
    switch (activityType) {
      case CareActivityType.medication:
        return 'Medication';
      case CareActivityType.toileting:
        return 'Toileting';
      case CareActivityType.hydration:
        return 'Hydration';
      case CareActivityType.meal:
        return 'Meal';
      case CareActivityType.behavior:
        return 'Behavior';
      case CareActivityType.photo:
        return 'Photo';
      case CareActivityType.note:
        return 'Note';
      case CareActivityType.pain:
        return 'Pain';
      case CareActivityType.vitals:
        return 'Vitals';
      case CareActivityType.location:
        return 'Location';
    }
  }

  String _getCleanDescription(String details, CareActivityType activityType) {
    // Remove common prefixes that repeat the activity type
    String cleanDetails = details;
    
    // Remove "Medicine: " prefix for medication
    if (activityType == CareActivityType.medication && details.toLowerCase().startsWith('medicine:')) {
      cleanDetails = details.substring(details.indexOf(':') + 1).trim();
    }
    
    // Remove "Behavior: " prefix for behavior
    if (activityType == CareActivityType.behavior && details.toLowerCase().startsWith('behavior:')) {
      cleanDetails = details.substring(details.indexOf(':') + 1).trim();
    }
    
    // Remove "Location: " prefix for location
    if (activityType == CareActivityType.location && details.toLowerCase().startsWith('location:')) {
      cleanDetails = details.substring(details.indexOf(':') + 1).trim();
    }
    
    // Remove "Note: " prefix for notes
    if (activityType == CareActivityType.note && details.toLowerCase().startsWith('note:')) {
      cleanDetails = details.substring(details.indexOf(':') + 1).trim();
    }
    
    // Remove "Meal: " prefix for meals
    if (activityType == CareActivityType.meal && details.toLowerCase().startsWith('meal:')) {
      cleanDetails = details.substring(details.indexOf(':') + 1).trim();
    }
    
    // Remove "Hydration: " prefix for hydration
    if (activityType == CareActivityType.hydration && details.toLowerCase().startsWith('hydration:')) {
      cleanDetails = details.substring(details.indexOf(':') + 1).trim();
    }
    
    // Remove "Toileting: " prefix for toileting
    if (activityType == CareActivityType.toileting && details.toLowerCase().startsWith('toileting:')) {
      cleanDetails = details.substring(details.indexOf(':') + 1).trim();
    }
    
    return cleanDetails;
  }

  IconData _getActivityIcon(CareActivityType activityType) {
    switch (activityType) {
      case CareActivityType.medication:
        return Icons.medication_rounded;
      case CareActivityType.toileting:
        return Icons.wc_rounded;
      case CareActivityType.hydration:
        return Icons.water_drop_rounded;
      case CareActivityType.meal:
        return Icons.restaurant_rounded;
      case CareActivityType.behavior:
        return Icons.psychology_rounded;
      case CareActivityType.photo:
        return Icons.camera_alt_rounded;
      case CareActivityType.note:
        return Icons.note_rounded;
      case CareActivityType.pain:
        return Icons.sick_rounded;
      case CareActivityType.vitals:
        return Icons.favorite_rounded;
      case CareActivityType.location:
        return Icons.location_on_rounded;
    }
  }



  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }


} 