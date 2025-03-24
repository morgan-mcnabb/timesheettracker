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
    this.createdAt,
    this.modifiedAt,
    this.name,
    this.email,
    this.phone,
    this.website,
    this.userId,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'].toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      modifiedAt: json['modified_at'] != null
          ? DateTime.parse(json['modified_at'])
          : null,
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      userId: json['user_id'],
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
