import 'package:timesheettracker/models/address.dart';
import 'package:timesheettracker/models/contact.dart';

class Client {
  final String? id;
  final String name;
  final Contact? contact;
  final Address? address;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final String? userId;

  Client({
    this.id,
    required this.name,
    this.contact,
    this.address,
    this.createdAt,
    this.modifiedAt,
    this.userId,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      contact:
          json['contact'] != null ? Contact.fromJson(json['contact']) : null,
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      modifiedAt: json['modified_at'] != null
          ? DateTime.parse(json['modified_at'])
          : null,
      userId: json['user_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'name': name,
      'contact': contact?.id,
      'address': address?.id,
      'user_id': userId,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  @override
  String toString() {
    return 'Client(id: $id, name: $name)';
  }
}
