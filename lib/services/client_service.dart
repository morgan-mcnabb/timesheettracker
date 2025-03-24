import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timesheettracker/models/client.dart';
import 'package:timesheettracker/services/auth_service.dart';

class ClientService {
  final SupabaseClient _supabase = Supabase.instance.client;

  ClientService._();

  static Future<ClientService> create() async {
    return ClientService._();
  }

  Future<Client> createClient(Client client) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('clients')
          .insert(client.toJson()..['user_id'] = user.id)
          .select()
          .single();
      return Client.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create client: $e');
    }
  }

  Future<List<Client>> getClients() async {
    try {
      final user = AuthService.getCurrentUser();

      final response = await _supabase.from('clients').select('''
              id,
              name,
              contact:contacts(
                id,
                name,
                email,
                phone,
                website),
              address:addresses(
                id,
                street_1,
                street_2,
                city,
                state_province,
                postal_code,
                country)''').eq('user_id', user.id);

      if (response == null || (response as List).isEmpty) {
        return [];
      }

      final data = response as List<dynamic>;
      return data.map((clientJson) => Client.fromJson(clientJson)).toList();
    } catch (e) {
      if (e.toString().contains('No authenticated user found')) {
        return [];
      }
      throw Exception('Failed to get clients: $e');
    }
  }

  Future<Client> updateClient(Client client) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('clients')
          .update(client.toJson())
          .eq('id', client.id ?? '')
          .eq('user_id', user.id)
          .select(
              'id, name, contact:contacts(id, name, email, phone, website), address:addresses(id, street_1, street_2, city, state_province, postal_code, country)')
          .single();
      return Client.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update client: $e');
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      final user = AuthService.getCurrentUser();
      await _supabase
          .from('clients')
          .delete()
          .eq('id', clientId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to delete client: $e');
    }
  }

  Future<Client> getClientById(String clientId) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('clients')
          .select(
              'id, name, contact:contacts(id, name, email, phone, website), address:addresses(id, street_1, street_2, city, state_province, postal_code, country)')
          .eq('id', clientId)
          .eq('user_id', user.id)
          .single();
      return Client.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get client by id: $e');
    }
  }

  Future<List<Client>> getClientsForUser(String userId) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('clients')
          .select(
              'id, name, contact:contacts(id, name, email, phone, website), address:addresses(id, street_1, street_2, city, state_province, postal_code, country)')
          .eq('user_id', user.id);
      return response.map((clientJson) => Client.fromJson(clientJson)).toList();
    } catch (e) {
      throw Exception('Failed to get clients for user: $e');
    }
  }

  Future<List<Client>> getClientsForContact(String contactId) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('clients')
          .select(
              'id, name, contact:contacts(id, name, email, phone, website), address:addresses(id, street_1, street_2, city, state_province, postal_code, country)')
          .eq('contact_id', contactId)
          .eq('user_id', user.id);
      return response.map((clientJson) => Client.fromJson(clientJson)).toList();
    } catch (e) {
      throw Exception('Failed to get clients for contact: $e');
    }
  }

  Future<List<Client>> getClientsForAddress(String addressId) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('clients')
          .select(
              'id, name, contact:contacts(id, name, email, phone, website), address:addresses(id, street_1, street_2, city, state_province, postal_code, country)')
          .eq('address_id', addressId)
          .eq('user_id', user.id);
      return response.map((clientJson) => Client.fromJson(clientJson)).toList();
    } catch (e) {
      throw Exception('Failed to get clients for address: $e');
    }
  }

  Future<List<Client>> getClientsForTask(String taskId) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('clients')
          .select(
              'id, name, contact:contacts(id, name, email, phone, website), address:addresses(id, street_1, street_2, city, state_province, postal_code, country)')
          .eq('task_id', taskId)
          .eq('user_id', user.id);
      return response.map((clientJson) => Client.fromJson(clientJson)).toList();
    } catch (e) {
      throw Exception('Failed to get clients for task: $e');
    }
  }

  Future<List<Client>> getClientsForTimeEntry(String timeEntryId) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('clients')
          .select(
              'id, name, contact:contacts(id, name, email, phone, website), address:addresses(id, street_1, street_2, city, state_province, postal_code, country)')
          .eq('time_entry_id', timeEntryId)
          .eq('user_id', user.id);
      return response.map((clientJson) => Client.fromJson(clientJson)).toList();
    } catch (e) {
      throw Exception('Failed to get clients for time entry: $e');
    }
  }

  Future<List<Client>> getClientsForInvoice(String invoiceId) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('clients')
          .select(
              'id, name, contact:contacts(id, name, email, phone, website), address:addresses(id, street_1, street_2, city, state_province, postal_code, country)')
          .eq('invoice_id', invoiceId)
          .eq('user_id', user.id);
      return response.map((clientJson) => Client.fromJson(clientJson)).toList();
    } catch (e) {
      throw Exception('Failed to get clients for invoice: $e');
    }
  }

  Future<List<Client>> getClientsForPayment(String paymentId) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('clients')
          .select(
              'id, name, contact:contacts(id, name, email, phone, website), address:addresses(id, street_1, street_2, city, state_province, postal_code, country)')
          .eq('payment_id', paymentId)
          .eq('user_id', user.id);
      return response.map((clientJson) => Client.fromJson(clientJson)).toList();
    } catch (e) {
      throw Exception('Failed to get clients for payment: $e');
    }
  }

  Future<List<Client>> getClientsForProject(String projectId) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('clients')
          .select(
              'id, name, contact:contacts(id, name, email, phone, website), address:addresses(id, street_1, street_2, city, state_province, postal_code, country)')
          .eq('project_id', projectId)
          .eq('user_id', user.id);
      return response.map((clientJson) => Client.fromJson(clientJson)).toList();
    } catch (e) {
      throw Exception('Failed to get clients for project: $e');
    }
  }
}
