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
    this.createdAt,
    this.modifiedAt,
    this.street1,
    this.street2,
    this.city,
    this.stateProvince,
    this.postalCode,
    this.country,
    this.userId,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'].toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      modifiedAt: json['modified_at'] != null
          ? DateTime.parse(json['modified_at'])
          : null,
      street1: json['street_1'],
      street2: json['street_2'],
      city: json['city'],
      stateProvince: json['state_province'],
      postalCode: json['postal_code'] != null
          ? int.tryParse(json['postal_code'].toString())
          : null,
      country: json['country'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street_1': street1,
      'street_2': street2,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
