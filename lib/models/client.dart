import 'xata_metadata.dart';

class Client {
  final String? id;
  final String clientName;
  final double hourlyRate;
  final XataMetadata xata;

  Client({
    required this.id,
    required this.clientName,
    required this.hourlyRate,
    required this.xata,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      clientName: json['client_name'],
      hourlyRate: (json['hourly_rate'] is int)
          ? (json['hourly_rate'] as int).toDouble()
          : json['hourly_rate'].toDouble(),
      xata: XataMetadata.fromJson(json['xata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_name': clientName,
      'hourly_rate': hourlyRate,
      if (id != null) 'id': id,
    };
  }
}
