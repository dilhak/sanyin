import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tasks_controller.dart';
import '../models/task_model.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: Colors.transparent,
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
                  _showClearTasksDialog();
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
                    const Text('Clear All Tasks'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 18, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    const Text('Export Tasks'),
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
          // Tasks list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredTasks = controller.filteredTasks;
              
              if (filteredTasks.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.loadTasks,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return _buildTaskCard(task);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => controller.showAddEditTaskDialog(),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 28),
        ),
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
          if (controller.selectedStatus.value != null)
            Chip(
              label: Text(controller.getTaskStatusLabel(controller.selectedStatus.value!)),
              onDeleted: () => controller.setStatusFilter(null),
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              deleteIcon: const Icon(Icons.close, color: Colors.blue),
            ),
          if (controller.selectedPriority.value != null)
            Chip(
              label: Text(controller.selectedPriority.value!.name.toUpperCase()),
              onDeleted: () => controller.setPriorityFilter(null),
              backgroundColor: controller.getTaskPriorityColor(controller.selectedPriority.value!).withValues(alpha: 0.1),
              deleteIcon: Icon(Icons.close, color: controller.getTaskPriorityColor(controller.selectedPriority.value!)),
            ),
          if (controller.selectedCategory.value.isNotEmpty)
            Chip(
              label: Text(controller.selectedCategory.value),
              onDeleted: () => controller.setCategoryFilter(''),
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              deleteIcon: const Icon(Icons.close, color: Colors.green),
            ),
          if (controller.selectedStatus.value != null || controller.selectedPriority.value != null || controller.selectedCategory.value.isNotEmpty)
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
          Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first task to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.showAddEditTaskDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add First Task'),
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

  Widget _buildTaskCard(Task task) {
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
            color: controller.getTaskPriorityColor(task.priority).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            controller.getTaskStatusIcon(task.status),
            color: controller.getTaskPriorityColor(task.priority),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  decoration: task.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: controller.getTaskPriorityColor(task.priority).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.priority.name.toUpperCase(),
                style: TextStyle(
                  color: controller.getTaskPriorityColor(task.priority),
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
            if (task.description != null && task.description!.isNotEmpty)
              Text(
                task.description!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (task.dueDate != null) ...[
                  Icon(Icons.schedule, color: Colors.grey[500], size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _formatDueDate(task.dueDate!),
                    style: TextStyle(
                      color: task.isOverdue ? Colors.red[600] : Colors.grey[500],
                      fontSize: 12,
                      fontWeight: task.isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
                if (task.assignedTo != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.person, color: Colors.grey[500], size: 14),
                  const SizedBox(width: 4),
                  Text(
                    task.assignedTo!,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
                if (task.category != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.category, color: Colors.grey[500], size: 14),
                  const SizedBox(width: 4),
                  Text(
                    task.category!,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            if (task.status == TaskStatus.completed) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'COMPLETED',
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
        trailing: IconButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onPressed: () => controller.showTaskActions(task),
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
              'Filter Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Status filter
            DropdownButtonFormField<TaskStatus?>(
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              value: controller.selectedStatus.value,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Statuses')),
                ...TaskStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(controller.getTaskStatusLabel(status)),
                )),
              ],
              onChanged: controller.setStatusFilter,
            ),
            const SizedBox(height: 16),
            // Priority filter
            DropdownButtonFormField<TaskPriority?>(
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              value: controller.selectedPriority.value,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Priorities')),
                ...TaskPriority.values.map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority.name.toUpperCase()),
                )),
              ],
              onChanged: controller.setPriorityFilter,
            ),
            const SizedBox(height: 16),
            // Show completed filter
            Obx(() => SwitchListTile(
              title: const Text('Show Completed'),
              value: controller.showCompleted.value,
              onChanged: (value) => controller.toggleCompletedFilter(),
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

  void _showClearTasksDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All Tasks'),
        content: const Text('Are you sure you want to clear all tasks? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement clear all tasks
              Get.back();
              Get.snackbar(
                'Tasks Cleared',
                'All tasks have been cleared',
                backgroundColor: Colors.orange[100],
                colorText: Colors.orange[800],
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (dueDay.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dueDay.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    }
  }
} 