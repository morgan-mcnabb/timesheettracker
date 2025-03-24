import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timesheettracker/models/contact.dart';
import 'package:timesheettracker/services/auth_service.dart';

class ContactService {
  final SupabaseClient _supabase = Supabase.instance.client;

  ContactService._();

  static Future<ContactService> create() async {
    return ContactService._();
  }

  Future<Contact> createContact(Contact contact) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('contacts')
          .insert(contact.toJson()..['user_id'] = user.id)
          .select()
          .single();
      return Contact.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create contact: $e');
    }
  }

  Future<List<Contact>> getContacts() async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('contacts')
          .select('id, name, email, phone, website')
          .eq('user_id', user.id)
          .order('created_at');
      return response
          .map((contactJson) => Contact.fromJson(contactJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to load contacts: $e');
    }
  }

  Future<Contact> updateContact(Contact contact) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('contacts')
          .update(contact.toJson())
          .eq('id', contact.id)
          .eq('user_id', user.id)
          .select()
          .single();
      return Contact.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update contact: $e');
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      final user = AuthService.getCurrentUser();
      await _supabase
          .from('contacts')
          .delete()
          .eq('id', contactId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to delete contact: $e');
    }
  }

  Future<Contact> getContactById(String contactId) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('contacts')
          .select('id, name, email, phone, website')
          .eq('id', contactId)
          .eq('user_id', user.id)
          .single();
      return Contact.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get contact by id: $e');
    }
  }

  Future<List<Contact>> getContactsForClient(String clientId) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('contacts')
          .select('id, name, email, phone, website')
          .eq('client_id', clientId)
          .eq('user_id', user.id);
      return response
          .map((contactJson) => Contact.fromJson(contactJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to get contacts for client: $e');
    }
  }
}
