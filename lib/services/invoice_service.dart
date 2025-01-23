import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/invoice.dart';

class InvoiceService {
  final supabase = Supabase.instance.client;

  InvoiceService._();

  static Future<InvoiceService> create() async {
    return InvoiceService._();
  }

  Future<List<Invoice>> getInvoices() async {
    try {
      final user = AuthService.getCurrentUser();

      final response = await supabase
          .from('invoices')
          .select('id, invoice_number, created_at, total_amount')
          .eq('user_id', user.id)
          .order('created_at');

      final data = response as List<dynamic>;
      return data.map((invoiceJson) => Invoice.fromJson(invoiceJson)).toList();
    } catch (e) {
      throw Exception('Failed to load invoices: $e');
    }
  }

  Future<String> createInvoice({
    required String invoiceNumber,
    required double totalAmount,
  }) async {
    try {
      final user = AuthService.getCurrentUser();

      final response = await supabase.from('invoices').insert({
        'invoice_number': invoiceNumber,
        'total_amount': totalAmount,
        'user_id': user.id,
      }).select('id');

      if (response.isNotEmpty) {
        final insertedRecord = response.first;
        return insertedRecord['id'].toString();
      }

      throw Exception('Failed to retrieve newly created invoice ID.');
    } catch (e) {
      throw Exception('Failed to create invoice: $e');
    }
  }
}
