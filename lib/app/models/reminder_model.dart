class Reminder {
  final int? id;
  final int clientId;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final bool isActive;
  final String? frequency; // daily, weekly, monthly, custom
  final DateTime createdAt;

  Reminder({
    this.id,
    required this.clientId,
    required this.title,
    required this.description,
    required this.scheduledTime,
    this.isActive = true,
    this.frequency,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'title': title,
      'description': description,
      'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      'isActive': isActive ? 1 : 0,
      'frequency': frequency,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      clientId: map['clientId'],
      title: map['title'],
      description: map['description'],
      scheduledTime: DateTime.fromMillisecondsSinceEpoch(map['scheduledTime']),
      isActive: map['isActive'] == 1,
      frequency: map['frequency'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
} 