enum CareActivityType {
  medication,
  toileting,
  hydration,
  meal,
  behavior,
  photo,
  note,
}

enum MedicationAction { given, refused }

enum BowelMovementType { normal, constipated, diarrhea, incontinent }

enum UrinationType { clear, lightYellow, darkYellow, bloody, painful, frequent, incontinent }

enum HydrationType { goodIntake, poorIntake, refused }

enum MealType { breakfast, lunch, dinner, snacks }
enum MealIntakeType { ateAll, ateSome, refused }

enum MoodType { happy, sad, anxious, agitated, calm }
enum ActivityLevelType { active, resting, sleeping, unresponsive }
enum SocialInteractionType { engaged, withdrawn, cooperative, uncooperative }

class CareLog {
  final int? id;
  final int clientId;
  final CareActivityType activityType;
  final String? action;
  final String? subAction;
  final String? details;
  final String? photoPath;
  final DateTime timestamp;
  final String? notes;

  CareLog({
    this.id,
    required this.clientId,
    required this.activityType,
    this.action,
    this.subAction,
    this.details,
    this.photoPath,
    required this.timestamp,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'activityType': activityType.name,
      'action': action,
      'subAction': subAction,
      'details': details,
      'photoPath': photoPath,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory CareLog.fromMap(Map<String, dynamic> map) {
    return CareLog(
      id: map['id'],
      clientId: map['clientId'],
      activityType: CareActivityType.values.firstWhere(
        (e) => e.name == map['activityType'],
      ),
      action: map['action'],
      subAction: map['subAction'],
      details: map['details'],
      photoPath: map['photoPath'],
      timestamp: DateTime.parse(map['timestamp']),
      notes: map['notes'],
    );
  }
} 