import 'package:timesheettracker/models/client.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'dart:convert';

class ClientResponse {
  final List<Client> records;
  final bool hasMore;
  final String? nextCursor;
  final int pageSize;

  ClientResponse({
    required this.records,
    required this.hasMore,
    this.nextCursor,
    required this.pageSize,
  });

  factory ClientResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta']['page'];
    final records = (json['records'] as List)
        .map((record) => Client.fromJson(record))
        .toList();

    return ClientResponse(
      records: records,
      hasMore: meta['more'] ?? false,
      nextCursor: meta['cursor'],
      pageSize: meta['size'],
    );
  }
}

class ClientService {
  final String apiKey;
  final String databaseUrl;

  ClientService._({
    required this.apiKey,
    required this.databaseUrl,
  });

  static Future<ClientService> create() async {
    var env = DotEnv()..load();

    return ClientService._(
      apiKey: env['XATA_API_KEY'] ?? '',
      databaseUrl: env['XATA_DATABASE_URL'] ?? '',
    );
  }

  Future<ClientResponse> getClients() async {
    final response = await http.post(
      Uri.parse('$databaseUrl/db/time-tracking:main/tables/clients/query'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "columns": ["xata_id", "client_name", "hourly_rate"],
        "page": {"size": 500}
      }),
    );

    if (response.statusCode == 200) {
      final clientResponse = ClientResponse.fromJson(jsonDecode(response.body));
      return clientResponse;
    } else {
      throw Exception('Failed to load clients');
    }
  }

  Future<void> createClient(Client client) async {
    print('Creating client with data: ${client.toJson()}');

    final response = await http.post(
      Uri.parse('$databaseUrl/db/time-tracking:main/tables/clients/data'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(client.toJson()),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
          'Failed to create client: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteClient(String clientId) async {
    final response = await http.delete(
      Uri.parse(
          '$databaseUrl/db/time-tracking:main/tables/clients/data/$clientId'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to delete client: ${response.statusCode} - ${response.body}');
    }
  }
}
