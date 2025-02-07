class Address {
  final String id;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final String? street1;
  final String? street2;
  final String? city;
  final String? stateProvince;
  final int? postalCode;
  final String? country;
  final String? userId;

  Address({
    required this.id,
    required this.createdAt,
    required this.modifiedAt,
    required this.street1,
    required this.street2,
    required this.city,
    required this.stateProvince,
    required this.postalCode,
    required this.country,
    required this.userId,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'].toString(),
      createdAt: json['created_at']?.let((date) => DateTime.parse(date)),
      modifiedAt: json['modified_at']?.let((date) => DateTime.parse(date)),
      street1: json['street_1'] ?? '',
      street2: json['street_2'] ?? '',
      city: json['city'] ?? '',
      stateProvince: json['state_province'] ?? '',
      postalCode: json['postal_code'] ?? '',
      country: json['country'] ?? '',
      userId: json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street1': street1,
      'street2': street2,
      'city': city,
      'state_province': stateProvince,
      'postal_code': postalCode,
      'country': country,
      'user_id': userId,
    };
  }

  @override
  String toString() {
    return 'Address(id: $id, street1: $street1, street2: $street2, city: $city, stateProvince: $stateProvince, postalCode: $postalCode, country: $country, userId: $userId)';
  }
}
