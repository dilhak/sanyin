enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

class Task {
  final int? id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String? assignedTo;
  final String? category;
  final bool isRecurring;
  final String? recurrencePattern;
  final DateTime? completedAt;
  final String? completedBy;
  final String? notes;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.assignedTo,
    this.category,
    this.isRecurring = false,
    this.recurrencePattern,
    this.completedAt,
    this.completedBy,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.name,
      'status': status.name,
      'assignedTo': assignedTo,
      'category': category,
      'isRecurring': isRecurring ? 1 : 0,
      'recurrencePattern': recurrencePattern,
      'completedAt': completedAt?.toIso8601String(),
      'completedBy': completedBy,
      'notes': notes,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']!) : null,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
      ),
      assignedTo: map['assignedTo'],
      category: map['category'],
      isRecurring: map['isRecurring'] == 1,
      recurrencePattern: map['recurrencePattern'],
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']!) : null,
      completedBy: map['completedBy'],
      notes: map['notes'],
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedTo,
    String? category,
    bool? isRecurring,
    String? recurrencePattern,
    DateTime? completedAt,
    String? completedBy,
    String? notes,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      category: category ?? this.category,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      notes: notes ?? this.notes,
    );
  }

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final today = DateTime.now();
    final dueDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    return dueDay.isAtSameMomentAs(todayDay);
  }

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dueDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final tomorrowDay = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    return dueDay.isAtSameMomentAs(tomorrowDay);
  }
} 