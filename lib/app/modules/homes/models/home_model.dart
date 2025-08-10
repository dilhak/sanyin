class Home {
  final int? id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? clientCount; // Will be populated when loading with client counts

  Home({
    this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.clientCount,
  });

  factory Home.fromMap(Map<String, dynamic> map) {
    return Home(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      clientCount: map['clientCount']?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Home copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? clientCount,
  }) {
    return Home(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clientCount: clientCount ?? this.clientCount,
    );
  }

  @override
  String toString() {
    return 'Home(id: $id, name: $name, clientCount: $clientCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Home && other.id == id && other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }
}
