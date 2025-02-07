import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timesheettracker/services/client_service.dart';
import '../models/timesheet_model.dart';
import '../styles.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);
    final clients = timesheet.clients;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await timesheet.refreshClients();
            },
            tooltip: 'Refresh Clients',
          ),
        ],
      ),
      body: timesheet.isLoading
          ? const Center(child: CircularProgressIndicator())
          : clients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business,
                          size: 80, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        'No clients added yet.',
                        style: textTheme.bodyLarge
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(standardPadding),
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.business,
                                    color: colorScheme.primary, size: 30),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    client.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final scaffoldMessenger =
                                        ScaffoldMessenger.of(context);
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Client'),
                                        content: const Text(
                                            'Are you sure you want to delete this client?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  colorScheme.error,
                                              foregroundColor:
                                                  colorScheme.onError,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed == true) {
                                      try {
                                        final clientService =
                                            await ClientService.create();
                                        await clientService
                                            .deleteClient(client.id);
                                        await timesheet.refreshClients();

                                        if (context.mounted) {
                                          scaffoldMessenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Client deleted successfully'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          scaffoldMessenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Failed to delete client: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            if (client.contact != null ||
                                client.address != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (client.contact != null)
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.people,
                                              size: 16,
                                              color:
                                                  colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (client.contact?.name !=
                                                    null)
                                                  Text(client.contact!.name!),
                                                if (client.contact?.email !=
                                                    null)
                                                  Text(client.contact!.email!,
                                                      style: textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                      )),
                                                if (client.contact?.phone !=
                                                    null)
                                                  Text(client.contact!.phone!,
                                                      style: textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                      )),
                                                if (client.contact?.website !=
                                                    null)
                                                  Text(client.contact!.website!,
                                                      style: textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                      )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (client.contact != null &&
                                      client.address != null)
                                    const SizedBox(width: 16),
                                  if (client.address != null)
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.location_on,
                                              size: 16,
                                              color:
                                                  colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(client.address!.street1 ??
                                                    ''),
                                                if (client.address?.street2 !=
                                                        null &&
                                                    client.address!.street2!
                                                        .isNotEmpty)
                                                  Text(
                                                      client.address!.street2!),
                                                if (client.address?.city !=
                                                        null ||
                                                    client.address
                                                            ?.stateProvince !=
                                                        null ||
                                                    client.address
                                                            ?.postalCode !=
                                                        null)
                                                  Text(
                                                    [
                                                      client.address?.city,
                                                      client.address
                                                          ?.stateProvince,
                                                      client
                                                          .address?.postalCode,
                                                    ]
                                                        .where((e) => e != null)
                                                        .join(', '),
                                                  ),
                                                if (client.address?.country !=
                                                    null)
                                                  Text(
                                                      client.address!.country!),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ClientFormPage()));
        },
        tooltip: 'Add Client',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ClientFormPage extends StatelessWidget {
  const ClientFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Client')),
      body: const Center(child: Text('Add Client')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
