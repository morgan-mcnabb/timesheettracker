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
                        subtitle: Text(
                          'Created: ${invoice.createdAt.toLocal()}',
                          style: textTheme.bodySmall,
                        ),
                        trailing: Text(
                          '\$${invoice.totalAmount.toStringAsFixed(2)}',
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGenerateInvoiceDialog(context),
        label: const Text('Generate Invoice'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showGenerateInvoiceDialog(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context, listen: false);
    final allProjects = timesheet.projects;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final selectedProjectIds = <String>{};

        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Generate Invoice'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Project(s) to Invoice:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (allProjects.isEmpty)
                        const Text(
                          'No projects available.',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        Column(
                          children: allProjects.map((project) {
                            final alreadySelected =
                                selectedProjectIds.contains(project.id);
                            return CheckboxListTile(
                              title: Text(project.name),
                              value: alreadySelected,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    selectedProjectIds.add(project.id);
                                  } else {
                                    selectedProjectIds.remove(project.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        'Note: If no projects are selected, the invoice will include all un-invoiced entries.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final parentContext = this.context;
                    Navigator.of(dialogContext).pop();
                    await _generateInvoice(parentContext, selectedProjectIds.toList());
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Create Invoice'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _generateInvoice(
    BuildContext parentContext,
    List<String> projectIds,
  ) async {
    final timesheet = Provider.of<TimesheetModel>(parentContext, listen: false);

    try {
      final newInvoice = await timesheet.generateInvoice(
        invoiceNumber: DateTime.now().millisecondsSinceEpoch.toString(),
        projectIds: projectIds,
      );

      if (mounted) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(
            content: Text('Invoice #${newInvoice.invoiceNumber} created!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
