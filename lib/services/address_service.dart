import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timesheettracker/models/address.dart';
import 'package:timesheettracker/services/auth_service.dart';

class AddressService {
  final SupabaseClient _supabase = Supabase.instance.client;

  AddressService._();

  static Future<AddressService> create() async {
    return AddressService._();
  }

  Future<Address> createAddress(Address address) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('addresses')
          .insert(address.toJson()..['user_id'] = user.id)
          .select()
          .single();
      return Address.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create address: $e');
    }
  }

  Future<List<Address>> getAddresses() async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('addresses')
          .select('id, street, city, state, zip, country')
          .eq('user_id', user.id)
          .order('created_at');
      return response
          .map((addressJson) => Address.fromJson(addressJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to load addresses: $e');
    }
  }

  Future<Address> updateAddress(Address address) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('addresses')
          .update(address.toJson())
          .eq('id', address.id)
          .eq('user_id', user.id)
          .select()
          .single();
      return Address.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      final user = AuthService.getCurrentUser();
      await _supabase
          .from('addresses')
          .delete()
          .eq('id', addressId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  Future<Address> getAddressById(String addressId) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('addresses')
          .select('id, street, city, state, zip, country')
          .eq('id', addressId)
          .eq('user_id', user.id)
          .single();
      return Address.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get address by id: $e');
    }
  }

  Future<List<Address>> getAddressesForClient(String clientId) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('addresses')
          .select('id, street, city, state, zip, country')
          .eq('client_id', clientId)
          .eq('user_id', user.id);
      return response
          .map((addressJson) => Address.fromJson(addressJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to get addresses for client: $e');
    }
  }

  Future<List<Address>> getAddressesForContact(String contactId) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('addresses')
          .select('id, street, city, state, zip, country')
          .eq('contact_id', contactId)
          .eq('user_id', user.id);
      return response
          .map((addressJson) => Address.fromJson(addressJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to get addresses for contact: $e');
    }
  }
}
