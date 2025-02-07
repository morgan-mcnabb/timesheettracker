class Contact {
  final String id;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final String? name;
  final String? email;
  final String? phone;
  final String? website;
  final String? userId;

  Contact({
    required this.id,
    required this.createdAt,
    required this.modifiedAt,
    required this.name,
    required this.email,
    required this.phone,
    required this.website,
    required this.userId,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'].toString(),
      createdAt: json['created_at']?.let((date) => DateTime.parse(date)),
      modifiedAt: json['modified_at']?.let((date) => DateTime.parse(date)),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      userId: json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'website': website,
      'user_id': userId,
    };
  }

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, email: $email, phone: $phone, website: $website, userId: $userId)';
  }
}
