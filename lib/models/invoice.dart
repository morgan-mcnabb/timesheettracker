class Invoice {
  final String id;
  final String invoiceNumber;
  final DateTime createdAt;
  final double totalAmount; 

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.createdAt,
    required this.totalAmount,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'].toString(), 
      invoiceNumber: json['invoice_number'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      totalAmount: (json['total_amount'] is num) 
          ? (json['total_amount'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_number': invoiceNumber,
      'total_amount': totalAmount,
    };
  }
}