class Client {
  final int? id;
  final String name;
  final String? phoneNumber;
  final String? address;
  final String? emergencyContact;
  final String? medicalNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    this.id,
    required this.name,
    this.phoneNumber,
    this.address,
    this.emergencyContact,
    this.medicalNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'emergencyContact': emergencyContact,
      'medicalNotes': medicalNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      emergencyContact: map['emergencyContact'],
      medicalNotes: map['medicalNotes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
} 