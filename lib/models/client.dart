import 'package:timesheettracker/models/address.dart';
import 'package:timesheettracker/models/contact.dart';

class Client {
  final String id;
  final String name;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final Contact? contact;
  final Address? address;
  final String? userId;

  Client({
    required this.id,
    required this.name,
    this.createdAt,
    this.modifiedAt,
    this.contact,
    this.address,
    this.userId,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      createdAt: json['created_at']?.let((date) => DateTime.parse(date)),
      modifiedAt: json['modified_at']?.let((date) => DateTime.parse(date)),
      contact:
          json['contact'] != null ? Contact.fromJson(json['contact']) : null,
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      userId: json['user_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contact': contact?.toJson(),
      'address': address?.toJson(),
      'user_id': userId,
    };
  }

  @override
  String toString() {
    return 'Client(id: $id, name: $name)';
  }
}
