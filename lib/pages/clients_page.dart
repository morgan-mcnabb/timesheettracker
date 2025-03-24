import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timesheettracker/models/address.dart';
import 'package:timesheettracker/services/client_service.dart';
import '../models/contact.dart';
import '../models/client.dart';
import '../models/timesheet_model.dart';
import '../styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ClientFormPage(client: client),
                                      ),
                                    );
                                  },
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
                                            .deleteClient(client.id ?? '');
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

class ClientFormPage extends StatefulWidget {
  final Client? client;
  const ClientFormPage({super.key, this.client});

  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  Contact? selectedContact;
  Address? selectedAddress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name ?? '');
    selectedContact = widget.client?.contact;
    selectedAddress = widget.client?.address;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final timesheet = Provider.of<TimesheetModel>(context, listen: false);
      await Future.wait([
        timesheet.loadContacts(),
        timesheet.loadAddresses(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createNewContact() async {
    final Contact? newContact = await showDialog<Contact>(
      context: context,
      builder: (BuildContext context) => ContactFormDialog(),
    );

    if (newContact != null) {
      setState(() {
        selectedContact = newContact;
      });
    }
  }

  Future<void> _createNewAddress() async {
    final Address? newAddress = await showDialog<Address>(
      context: context,
      builder: (BuildContext context) => AddressFormDialog(),
    );

    if (newAddress != null) {
      setState(() {
        selectedAddress = newAddress;
      });
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('No authenticated user found');
      }

      final client = Client(
        id: widget.client?.id,
        name: _nameController.text,
        contact: selectedContact,
        address: selectedAddress,
        userId: userId,
      );

      final timesheet = Provider.of<TimesheetModel>(context, listen: false);
      if (widget.client != null) {
        await timesheet.updateClient(client);
      } else {
        await timesheet.addClient(client);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Client ${widget.client != null ? 'updated' : 'added'} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client != null ? 'Edit Client' : 'Add Client'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Client Name *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a client name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Contact Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Contact Information',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('New Contact'),
                        onPressed: _createNewContact,
                      ),
                    ],
                  ),
                  if (timesheet.contacts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                          'No contacts available. Create one using the + button above.'),
                    )
                  else
                    DropdownButtonFormField<Contact>(
                      value: selectedContact,
                      hint: const Text('Select a contact'),
                      items: timesheet.contacts.map((Contact contact) {
                        return DropdownMenuItem<Contact>(
                          key: ValueKey(contact.id),
                          value: contact,
                          child: Text('${contact.name} (${contact.email})'),
                        );
                      }).toList(),
                      onChanged: (Contact? newValue) {
                        setState(() {
                          selectedContact = newValue;
                        });
                      },
                    ),
                  if (selectedContact != null) ...[
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Contact Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Edit Contact',
                                      onPressed: () async {
                                        final Contact? updatedContact =
                                            await showDialog<Contact>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              ContactFormDialog(
                                            contact: selectedContact,
                                          ),
                                        );
                                        if (updatedContact != null) {
                                          setState(() {
                                            selectedContact = updatedContact;
                                          });
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      tooltip: 'Remove Contact',
                                      onPressed: () {
                                        setState(() {
                                          selectedContact = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            if (selectedContact!.name != null)
                              Text('Name: ${selectedContact!.name}'),
                            if (selectedContact!.email != null)
                              Text('Email: ${selectedContact!.email}'),
                            if (selectedContact!.phone != null)
                              Text('Phone: ${selectedContact!.phone}'),
                            if (selectedContact!.website != null)
                              Text('Website: ${selectedContact!.website}'),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Address Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Address',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('New Address'),
                        onPressed: _createNewAddress,
                      ),
                    ],
                  ),
                  if (timesheet.addresses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                          'No addresses available. Create one using the + button above.'),
                    )
                  else
                    DropdownButtonFormField<Address>(
                      value: selectedAddress,
                      hint: const Text('Select an address'),
                      items: timesheet.addresses.map((Address address) {
                        return DropdownMenuItem<Address>(
                          key: ValueKey(address.id),
                          value: address,
                          child: Text('${address.street1}, ${address.city}'),
                        );
                      }).toList(),
                      onChanged: (Address? newValue) {
                        setState(() {
                          selectedAddress = newValue;
                        });
                      },
                    ),
                  if (selectedAddress != null) ...[
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Address Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Edit Address',
                                      onPressed: () async {
                                        final Address? updatedAddress =
                                            await showDialog<Address>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AddressFormDialog(
                                            address: selectedAddress,
                                          ),
                                        );
                                        if (updatedAddress != null) {
                                          setState(() {
                                            selectedAddress = updatedAddress;
                                          });
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      tooltip: 'Remove Address',
                                      onPressed: () {
                                        setState(() {
                                          selectedAddress = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            Text(selectedAddress!.street1 ?? ''),
                            if (selectedAddress!.street2 != null &&
                                selectedAddress!.street2!.isNotEmpty)
                              Text(selectedAddress!.street2!),
                            Text([
                              selectedAddress!.city,
                              selectedAddress!.stateProvince,
                              selectedAddress!.postalCode?.toString(),
                            ]
                                .where((e) => e != null && e.isNotEmpty)
                                .join(', ')),
                            if (selectedAddress!.country != null)
                              Text(selectedAddress!.country!),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _saveClient,
        child: const Icon(Icons.save),
      ),
    );
  }
}

// Contact Form Dialog
class ContactFormDialog extends StatefulWidget {
  final Contact? contact;

  const ContactFormDialog({super.key, this.contact});

  @override
  State<ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<ContactFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phone ?? '');
    _websiteController =
        TextEditingController(text: widget.contact?.website ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Contact'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email *'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(labelText: 'Website'),
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId == null) {
                  throw Exception('No authenticated user found');
                }

                final contact = Contact(
                  id: widget.contact?.id ?? '',
                  createdAt: widget.contact?.createdAt,
                  modifiedAt: null,
                  name: _nameController.text,
                  email: _emailController.text,
                  phone: _phoneController.text,
                  website: _websiteController.text,
                  userId: userId,
                );

                final timesheet =
                    Provider.of<TimesheetModel>(context, listen: false);
                final updatedContact = widget.contact != null
                    ? await timesheet.updateContact(contact)
                    : await timesheet.addContact(contact);
                Navigator.pop(context, updatedContact);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Error ${widget.contact != null ? 'updating' : 'creating'} contact: $e')),
                );
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Address Form Dialog
class AddressFormDialog extends StatefulWidget {
  final Address? address;

  const AddressFormDialog({super.key, this.address});

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _street1Controller;
  late TextEditingController _street2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateProvinceController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _street1Controller =
        TextEditingController(text: widget.address?.street1 ?? '');
    _street2Controller =
        TextEditingController(text: widget.address?.street2 ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateProvinceController =
        TextEditingController(text: widget.address?.stateProvince ?? '');
    _postalCodeController = TextEditingController(
        text: widget.address?.postalCode?.toString() ?? '');
    _countryController =
        TextEditingController(text: widget.address?.country ?? '');
  }

  @override
  void dispose() {
    _street1Controller.dispose();
    _street2Controller.dispose();
    _cityController.dispose();
    _stateProvinceController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Address'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _street1Controller,
                  decoration:
                      const InputDecoration(labelText: 'Street Address *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a street address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _street2Controller,
                  decoration:
                      const InputDecoration(labelText: 'Street Address 2'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stateProvinceController,
                  decoration:
                      const InputDecoration(labelText: 'State/Province *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a state/province';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(labelText: 'Postal Code *'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a postal code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(labelText: 'Country'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId == null) {
                  throw Exception('No authenticated user found');
                }

                final address = Address(
                  id: widget.address?.id ?? '',
                  createdAt: widget.address?.createdAt,
                  modifiedAt: null,
                  street1: _street1Controller.text,
                  street2: _street2Controller.text,
                  city: _cityController.text,
                  stateProvince: _stateProvinceController.text,
                  postalCode: int.tryParse(_postalCodeController.text),
                  country: _countryController.text,
                  userId: userId,
                );

                final timesheet =
                    Provider.of<TimesheetModel>(context, listen: false);
                final updatedAddress = widget.address != null
                    ? await timesheet.updateAddress(address)
                    : await timesheet.addAddress(address);
                Navigator.pop(context, updatedAddress);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Error ${widget.address != null ? 'updating' : 'creating'} address: $e')),
                );
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
