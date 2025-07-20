import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../../../services/database_service.dart';
import '../../../core/error_handler.dart';
import '../../../widgets/universal_popup.dart';

class TasksController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final ErrorHandler _errorHandler = ErrorHandler();
  
  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<TaskStatus?> selectedStatus = Rx<TaskStatus?>(null);
  final Rx<TaskPriority?> selectedPriority = Rx<TaskPriority?>(null);
  final RxBool showCompleted = false.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxString selectedCategory = ''.obs;

  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController assignedToController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final Rx<TaskPriority> selectedFormPriority = TaskPriority.medium.obs;
  final Rx<DateTime?> selectedDueDate = Rx<DateTime?>(null);
  final RxBool isRecurring = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    assignedToController.dispose();
    categoryController.dispose();
    notesController.dispose();
    
    // Clear all reactive variables to prevent memory leaks
    tasks.clear();
    selectedStatus.value = null;
    selectedPriority.value = null;
    selectedDate.value = null;
    selectedCategory.value = '';
    selectedFormPriority.value = TaskPriority.medium;
    selectedDueDate.value = null;
    isRecurring.value = false;
    
    super.onClose();
  }

  Future<void> loadTasks() async {
    isLoading.value = true;
    try {
      final tasksList = await _databaseService.getAllTasks();
      tasks.value = tasksList;
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    } finally {
      isLoading.value = false;
    }
  }

  List<Task> get filteredTasks {
    List<Task> filtered = tasks;

    // Filter by status
    if (selectedStatus.value != null) {
      filtered = filtered.where((task) => task.status == selectedStatus.value).toList();
    }

    // Filter by priority
    if (selectedPriority.value != null) {
      filtered = filtered.where((task) => task.priority == selectedPriority.value).toList();
    }

    // Filter by completion status
    if (!showCompleted.value) {
      filtered = filtered.where((task) => task.status != TaskStatus.completed).toList();
    }

    // Filter by date
    if (selectedDate.value != null) {
      final selectedDay = selectedDate.value!;
      filtered = filtered.where((task) {
        if (task.dueDate == null) return false;
        final taskDay = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        return taskDay.isAtSameMomentAs(selectedDay);
      }).toList();
    }

    // Filter by category
    if (selectedCategory.value.isNotEmpty) {
      filtered = filtered.where((task) => task.category == selectedCategory.value).toList();
    }

    // Sort by priority and due date
    filtered.sort((a, b) {
      // First sort by priority (urgent first)
      final priorityOrder = {TaskPriority.urgent: 0, TaskPriority.high: 1, TaskPriority.medium: 2, TaskPriority.low: 3};
      final priorityDiff = priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
      if (priorityDiff != 0) return priorityDiff;

      // Then sort by due date (earliest first)
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    return filtered;
  }

  List<Task> get overdueTasks {
    return tasks.where((task) => task.isOverdue && task.status != TaskStatus.completed).toList();
  }

  List<Task> get dueTodayTasks {
    return tasks.where((task) => task.isDueToday && task.status != TaskStatus.completed).toList();
  }

  List<Task> get dueTomorrowTasks {
    return tasks.where((task) => task.isDueTomorrow && task.status != TaskStatus.completed).toList();
  }

  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    String? assignedTo,
    String? category,
    bool isRecurring = false,
    String? recurrencePattern,
    String? notes,
  }) async {
    try {
      final task = Task(
        title: title,
        description: description,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        priority: priority,
        assignedTo: assignedTo,
        category: category,
        isRecurring: isRecurring,
        recurrencePattern: recurrencePattern,
        notes: notes,
      );

      await _databaseService.insertTask(task);
      await loadTasks();
      
      _errorHandler.showSuccessSnackbar('Task added successfully');
      _clearForm();
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  Future<void> updateTask(Task task, {
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedTo,
    String? category,
    bool? isRecurring,
    String? recurrencePattern,
    String? notes,
  }) async {
    try {
      final updatedTask = task.copyWith(
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        status: status,
        assignedTo: assignedTo,
        category: category,
        isRecurring: isRecurring,
        recurrencePattern: recurrencePattern,
        notes: notes,
      );

      await _databaseService.updateTask(updatedTask);
      await loadTasks();
      
      _errorHandler.showSuccessSnackbar('Task updated successfully');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  Future<void> completeTask(Task task, String completedBy) async {
    try {
      final completedTask = task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
        completedBy: completedBy,
      );

      await _databaseService.updateTask(completedTask);
      await loadTasks();
      
      _errorHandler.showSuccessSnackbar('Task marked as completed');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      await _databaseService.deleteTask(task.id!);
      await loadTasks();
      
      _errorHandler.showSuccessSnackbar('Task deleted successfully');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  void showTaskActions(Task task) {
    UniversalPopup.show(
      title: task.title,
      subtitle: task.description ?? 'No description',
      icon: getTaskStatusIcon(task.status),
      color: getTaskPriorityColor(task.priority),
      actions: [
        PopupAction(
          title: 'Edit',
          icon: Icons.edit,
          color: Colors.blue,
          onTap: () => _editTask(task),
        ),
        if (task.status != TaskStatus.completed)
          PopupAction(
            title: 'Complete',
            icon: Icons.check_circle,
            color: Colors.green,
            onTap: () => _completeTask(task),
          ),
        PopupAction(
          title: 'Delete',
          icon: Icons.delete,
          color: Colors.red,
          onTap: () => _deleteTask(task),
        ),
      ],
    );
  }

  void _editTask(Task task) {
    Get.back();
    _populateForm(task);
    showAddEditTaskDialog(isEditing: true, task: task);
  }

  void _completeTask(Task task) {
    Get.back();
    completeTask(task, 'Current User'); // TODO: Get actual user
  }

  void _deleteTask(Task task) {
    Get.back();
    UniversalPopup.showConfirmation(
      title: 'Delete Task',
      message: 'Are you sure you want to delete this task? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
      onConfirm: () => deleteTask(task),
    );
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    assignedToController.clear();
    categoryController.clear();
    notesController.clear();
    selectedFormPriority.value = TaskPriority.medium;
    selectedDueDate.value = null;
    isRecurring.value = false;
  }

  void _populateForm(Task task) {
    titleController.text = task.title;
    descriptionController.text = task.description ?? '';
    assignedToController.text = task.assignedTo ?? '';
    categoryController.text = task.category ?? '';
    notesController.text = task.notes ?? '';
    selectedFormPriority.value = task.priority;
    selectedDueDate.value = task.dueDate;
    isRecurring.value = task.isRecurring;
  }

  void showAddEditTaskDialog({bool isEditing = false, Task? task}) {
    if (isEditing && task != null) {
      _populateForm(task);
    } else {
      _clearForm();
    }

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
            Text(
              isEditing ? 'Edit Task' : 'Add New Task',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: assignedToController,
                    decoration: const InputDecoration(
                      labelText: 'Assigned To (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<TaskPriority>(
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              value: selectedFormPriority.value,
              items: TaskPriority.values.map((priority) => DropdownMenuItem(
                value: priority,
                child: Text(priority.name.toUpperCase()),
              )).toList(),
              onChanged: (value) => selectedFormPriority.value = value!,
            )),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _clearForm();
                      Get.back();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        if (isEditing && task != null) {
                          updateTask(task,
                            title: titleController.text,
                            description: descriptionController.text.isEmpty ? null : descriptionController.text,
                            dueDate: selectedDueDate.value,
                            priority: selectedFormPriority.value,
                            assignedTo: assignedToController.text.isEmpty ? null : assignedToController.text,
                            category: categoryController.text.isEmpty ? null : categoryController.text,
                            notes: notesController.text.isEmpty ? null : notesController.text,
                          );
                        } else {
                          addTask(
                            title: titleController.text,
                            description: descriptionController.text.isEmpty ? null : descriptionController.text,
                            dueDate: selectedDueDate.value,
                            priority: selectedFormPriority.value,
                            assignedTo: assignedToController.text.isEmpty ? null : assignedToController.text,
                            category: categoryController.text.isEmpty ? null : categoryController.text,
                            notes: notesController.text.isEmpty ? null : notesController.text,
                          );
                        }
                        _clearForm();
                        Get.back();
                      }
                    },
                    child: Text(isEditing ? 'Update' : 'Add Task'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  void clearFilters() {
    selectedStatus.value = null;
    selectedPriority.value = null;
    showCompleted.value = false;
    selectedDate.value = null;
    selectedCategory.value = '';
  }

  void setStatusFilter(TaskStatus? status) {
    selectedStatus.value = status;
  }

  void setPriorityFilter(TaskPriority? priority) {
    selectedPriority.value = priority;
  }

  void toggleCompletedFilter() {
    showCompleted.value = !showCompleted.value;
  }

  void setDateFilter(DateTime? date) {
    selectedDate.value = date;
  }

  void setCategoryFilter(String category) {
    selectedCategory.value = category;
  }

  Color getTaskPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }

  IconData getTaskStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.schedule;
      case TaskStatus.inProgress:
        return Icons.play_circle;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.cancelled:
        return Icons.cancel;
    }
  }

  String getTaskStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (taskDate == today) {
      return 'Today at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
} 