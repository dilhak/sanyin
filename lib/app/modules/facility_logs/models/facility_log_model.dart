enum FacilityLogType {
  clockInOut,
  breakTime,
  houseNote,
  supplies,
  complaint,
  checklist,
  maintenance,
  incident,
  visitor,
  medication,
  emergency,
  other,
}

enum FacilityLogPriority {
  low,
  medium,
  high,
  critical,
}

class FacilityLog {
  final int? id;
  final int homeId; // Add homeId to make logs specific to each home
  final String action;
  final String description;
  final DateTime timestamp;
  final FacilityLogType type;
  final FacilityLogPriority priority;
  final String? staffMember;
  final String? location;
  final Map<String, dynamic>? additionalData;
  final String? photoPath;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  FacilityLog({
    this.id,
    required this.homeId,
    required this.action,
    required this.description,
    required this.timestamp,
    required this.type,
    this.priority = FacilityLogPriority.medium,
    this.staffMember,
    this.location,
    this.additionalData,
    this.photoPath,
    this.isResolved = false,
    this.resolvedAt,
    this.resolvedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'homeId': homeId,
      'action': action,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'priority': priority.name,
      'staffMember': staffMember,
      'location': location,
      'additionalData': additionalData?.toString(),
      'photoPath': photoPath,
      'isResolved': isResolved ? 1 : 0,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
    };
  }

  factory FacilityLog.fromMap(Map<String, dynamic> map) {
    return FacilityLog(
      id: map['id'],
      homeId: map['homeId'],
      action: map['action'],
      description: map['description'],
      timestamp: DateTime.parse(map['timestamp']),
      type: FacilityLogType.values.firstWhere(
        (e) => e.name == map['type'],
      ),
      priority: FacilityLogPriority.values.firstWhere(
        (e) => e.name == map['priority'],
      ),
      staffMember: map['staffMember'],
      location: map['location'],
      additionalData: map['additionalData'] != null 
        ? (map['additionalData']!.toString().contains('{') 
            ? Map<String, dynamic>.from(map['additionalData']!)
            : <String, dynamic>{})
        : null,
      photoPath: map['photoPath'],
      isResolved: map['isResolved'] == 1,
      resolvedAt: map['resolvedAt'] != null ? DateTime.parse(map['resolvedAt']!) : null,
      resolvedBy: map['resolvedBy'],
    );
  }

  FacilityLog copyWith({
    int? id,
    int? homeId,
    String? action,
    String? description,
    DateTime? timestamp,
    FacilityLogType? type,
    FacilityLogPriority? priority,
    String? staffMember,
    String? location,
    Map<String, dynamic>? additionalData,
    String? photoPath,
    bool? isResolved,
    DateTime? resolvedAt,
    String? resolvedBy,
  }) {
    return FacilityLog(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      action: action ?? this.action,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      staffMember: staffMember ?? this.staffMember,
      location: location ?? this.location,
      additionalData: additionalData ?? this.additionalData,
      photoPath: photoPath ?? this.photoPath,
      isResolved: isResolved ?? this.isResolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
    );
  }
} 