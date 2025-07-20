class FacilityLog {
  final int? id;
  final String action;
  final String description;
  final DateTime timestamp;
  final String type;
  final String? additionalData;

  FacilityLog({
    this.id,
    required this.action,
    required this.description,
    required this.timestamp,
    required this.type,
    this.additionalData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'additionalData': additionalData,
    };
  }

  factory FacilityLog.fromMap(Map<String, dynamic> map) {
    return FacilityLog(
      id: map['id'],
      action: map['action'],
      description: map['description'],
      timestamp: DateTime.parse(map['timestamp']),
      type: map['type'],
      additionalData: map['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'additionalData': additionalData,
    };
  }

  factory FacilityLog.fromJson(Map<String, dynamic> json) {
    return FacilityLog(
      action: json['action'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      additionalData: json['additionalData'],
    );
  }
} 