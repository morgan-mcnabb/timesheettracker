import 'package:flutter/material.dart';
import 'package:timesheettracker/models/client.dart';
import 'package:timesheettracker/models/xata_metadata.dart';
import 'package:timesheettracker/services/client_service.dart';

class ClientListPage extends StatefulWidget {
  final List<Client> clients;
  final Function(Client) onAdd;
  final Function(int) onDelete;

  const ClientListPage({
    Key? key,
    required this.clients,
    required this.onAdd,
    required this.onDelete,
  }) : super(key: key);

  @override
  _ClientListPageState createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  void _addClient() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String clientName = '';
        double hourlyRate = 0.0;
        final _formKey = GlobalKey<FormState>();

        return AlertDialog(
          title: const Text('Add Client'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Project Name'),
                  onChanged: (value) {
                    clientName = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a client name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Hourly Rate (\$)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    hourlyRate = double.tryParse(value) ?? 0.0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an hourly rate';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.tryParse(value)! < 0) {
                      return 'Hourly rate cannot be negative';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final clientService = await ClientService.create();
                    final newClient = Client(
                      id: null,
                      clientName: clientName,
                      hourlyRate: hourlyRate,
                      xata: XataMetadata(
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        version: 1,
                      ),
                    );
                    await clientService.createClient(newClient);
                    final updatedClients = await clientService.getClients();
                    setState(() {
                      widget.clients.clear();
                      widget.clients.addAll(updatedClients.records);
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Error creating client: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      body: widget.clients.isEmpty
          ? const Center(
              child: Text(
                'No clients added yet.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: widget.clients.length,
              itemBuilder: (context, index) {
                final client = widget.clients[index];
                return ListTile(
                  title: Text(client.clientName),
                  subtitle: Text(
                      'Hourly Rate: \$${client.hourlyRate.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      try {
                        final clientService = await ClientService.create();
                        await clientService.deleteClient(client.id!);
                        final updatedClients = await clientService.getClients();
                        setState(() {
                          widget.clients.clear();
                          widget.clients.addAll(updatedClients.records);
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Error deleting client: ${e.toString()}'),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClient,
        tooltip: 'Add Client',
        child: const Icon(Icons.add),
      ),
    );
  }
}
