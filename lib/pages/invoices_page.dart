import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timesheet_model.dart';
import '../styles.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);
    final invoices = timesheet.invoices;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await timesheet.refreshInvoices();
            },
            tooltip: 'Refresh Invoices',
          )
        ],
      ),
      body: timesheet.isLoading
          ? const Center(child: CircularProgressIndicator())
          : invoices.isEmpty
              ? Center(
                  child: Text(
                    'No invoices yet.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(standardPadding),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(
                          Icons.receipt_long,
                          color: colorScheme.primary,
                          size: 30,
                        ),
                        title: Text(
                          'Invoice #${invoice.invoiceNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Created: ${invoice.createdAt.toLocal()}',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: Text(
                          '\$${invoice.totalAmount.toStringAsFixed(2)}',
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          // In future, can show invoice details, PDF, etc.
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generateInvoice(context),
        label: const Text('Generate Invoice'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _generateInvoice(BuildContext context) async {
    final timesheet = Provider.of<TimesheetModel>(context, listen: false);

    try {
      final newInvoice = await timesheet.generateInvoice(
        invoiceNumber: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice #${newInvoice.invoiceNumber} created!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
