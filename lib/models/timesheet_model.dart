import 'package:flutter/material.dart';
import 'package:timesheettracker/models/address.dart';
import 'package:timesheettracker/models/client.dart';
import 'package:timesheettracker/models/contact.dart';
import 'package:timesheettracker/services/client_service.dart';
import '../services/project_service.dart';
import 'dart:async';
import 'project.dart';
import 'time_entry.dart';
import '../services/time_entry_service.dart';
import '../services/invoice_service.dart';
import '../models/invoice.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectMetrics {
  final Project project;
  double hoursLogged;
  double earnings;

  ProjectMetrics({
    required this.project,
    this.hoursLogged = 0.0,
    this.earnings = 0.0,
  });
}

class TimesheetModel extends ChangeNotifier {
  List<TimeEntry> _timeEntries = [];
  List<Project> _projects = [];

  bool _isClockedIn = false;
  bool _isPaused = false;
  bool _isLoading = false;
  bool _showUninvoicedOnly = false;
  DateTime? _clockInTime;
  DateTime? _pauseTime;
  Duration _elapsed = Duration.zero;
  Duration _accumulated = Duration.zero;
  double _currentEarnings = 0.0;
  Project? _currentProject;
  Project? _selectedProjectFilter;
  Timer? _timer;
  String? _error;
  DateTime? _startDate;
  DateTime? _endDate;
  List<Invoice> _invoices = [];
  List<Client> _clients = [];
  List<Contact> _contacts = [];
  List<Address> _addresses = [];

  late final TimeEntryService _timeEntryService;
  late final InvoiceService _invoiceService;
  late final TaskService _taskService;
  late final ClientService _clientService;

  List<TimeEntry> get timeEntries => _timeEntries;
  List<Project> get projects => _projects;
  List<Invoice> get invoices => _invoices;
  bool get isClockedIn => _isClockedIn;
  bool get isPaused => _isPaused;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  bool get showUninvoicedOnly => _showUninvoicedOnly;
  DateTime? get clockInTime => _clockInTime;
  Duration get elapsed => _elapsed;
  double get currentEarnings => _currentEarnings;
  Project? get currentProject => _currentProject;
  String? get error => _error;
  Project? get selectedProjectFilter => _selectedProjectFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  List<Client> get clients => _clients;
  List<Contact> get contacts => _contacts;
  List<Address> get addresses => _addresses;

  List<ProjectMetrics> get projectMetrics {
    List<TimeEntry> filteredEntries = _applyDateFilter(_timeEntries);
    Map<String, ProjectMetrics> metricsMap = {};
    for (var project in _projects) {
      metricsMap[project.id] = ProjectMetrics(project: project);
    }
    for (var entry in filteredEntries) {
      if (metricsMap.containsKey(entry.project.id)) {
        metricsMap[entry.project.id]!.hoursLogged += entry.billableHours;
        metricsMap[entry.project.id]!.earnings += entry.totalEarnings;
      }
    }
    return metricsMap.values.toList();
  }

  void setShowUninvoicedOnly(bool value) {
    _showUninvoicedOnly = value;
    notifyListeners();
  }

  TimesheetModel() {
    _initServices();
  }

  Future<void> _initServices() async {
    _timeEntryService = await TimeEntryService.create();
    _invoiceService = await InvoiceService.create();
    _taskService = await TaskService.create();
    _clientService = await ClientService.create();
    await initializeData();
  }

  Future<void> initializeData() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.wait([
        refreshProjects(),
        refreshTimeEntries(),
        refreshInvoices(),
        refreshClients(),
        loadContacts(),
        loadAddresses(),
      ]);

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTimeEntries() async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _timeEntryService.getTimeEntries();
      _timeEntries = response.records;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Task>> getTasksForTimeEntry(String timeEntryId) async {
    try {
      return await _taskService.getTasksForTimeEntry(timeEntryId);
    } catch (e) {
      _error = 'Failed to fetch tasks: $e';
      notifyListeners();
      return [];
    }
  }

  Future<void> addTasksForTimeEntry({
    required String timeEntryId,
    required List<Task> tasks,
  }) async {
    try {
      for (final task in tasks) {
        final taskToCreate = Task(
          timeEntryId: timeEntryId,
          taskName: task.taskName,
          notes: task.notes,
        );
        await _taskService.createTask(taskToCreate);
      }
    } catch (e) {
      _error = 'Failed to add tasks: $e';
      notifyListeners();
    }
  }

  Future<void> addTimeEntry(
      {required TimeEntry entry, List<Task>? tasks}) async {
    try {
      final newEntryId = await _timeEntryService.createTimeEntry(entry);
      if (tasks != null && tasks.isNotEmpty) {
        await addTasksForTimeEntry(
          timeEntryId: newEntryId,
          tasks: tasks,
        );
      }
      await refreshTimeEntries();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  TimeEntry? findTimeEntryById(String entryId) {
    try {
      return _timeEntries.firstWhere((te) => te.id == entryId);
    } catch (_) {
      return null;
    }
  }

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void deleteProject(int index) {
    _projects.removeAt(index);
    notifyListeners();
  }

  void clockIn(Project project) {
    if (_isClockedIn) return;

    _isClockedIn = true;
    _isPaused = false;
    _clockInTime = DateTime.now();
    _elapsed = Duration.zero;
    _accumulated = Duration.zero;
    _currentEarnings = 0.0;
    _currentProject = project;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_clockInTime == null || _currentProject == null) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      _elapsed = _accumulated + now.difference(_clockInTime!);
      _currentEarnings =
          (_elapsed.inSeconds / 3600) * (_currentProject!.hourlyRate);
      notifyListeners();
    });
  }

  void pauseClock() {
    if (!_isClockedIn || _isPaused) return;

    _isPaused = true;
    _pauseTime = DateTime.now();
    _accumulated += DateTime.now().difference(_clockInTime!);
    _timer?.cancel();
    notifyListeners();
  }

  void resumeClock() {
    if (!_isClockedIn || !_isPaused || _currentProject == null) return;

    _isPaused = false;
    _clockInTime = DateTime.now();
    _pauseTime = null;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_clockInTime == null || _currentProject == null) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      _elapsed = _accumulated + now.difference(_clockInTime!);
      _currentEarnings =
          (_elapsed.inSeconds / 3600) * (_currentProject!.hourlyRate);
      notifyListeners();
    });
  }

  Future<void> clockOut({List<Task>? tasks}) async {
    if (!_isClockedIn || _currentProject == null || _clockInTime == null) {
      return;
    }
    final DateTime? clockOutTime;

    if (_isPaused && _pauseTime != null) {
      clockOutTime = _pauseTime;
    } else {
      clockOutTime = DateTime.now();
      _accumulated += clockOutTime.difference(_clockInTime!);
    }

    _isClockedIn = false;
    _isPaused = false;
    _timer?.cancel();

    final newEntry = TimeEntry(
      id: "",
      date:
          DateTime(_clockInTime!.year, _clockInTime!.month, _clockInTime!.day),
      startTime: _clockInTime!,
      endTime: clockOutTime!,
      project: _currentProject!,
      rate: _currentProject!.hourlyRate,
      projectName: _currentProject!.name,
      invoiceId: null,
    );

    await addTimeEntry(entry: newEntry, tasks: tasks);

    _elapsed = Duration.zero;
    _accumulated = Duration.zero;
    _currentEarnings = 0.0;
    _clockInTime = null;
    _currentProject = null;
    _pauseTime = null;

    notifyListeners();
  }

  Future<void> addManualTimeEntry(
      DateTime date, TimeOfDay startTime, TimeOfDay endTime, Project project,
      {List<Task>? tasks}) async {
    final preciseStart = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
      0, // manual entries have to be 0 because TimePicker sucks
    );
    final preciseEnd = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
      0, // time picker sucks
    );

    final newEntry = TimeEntry(
      id: null,
      date: DateTime(
        preciseStart.year,
        preciseStart.month,
        preciseStart.day,
      ),
      startTime: preciseStart,
      endTime: preciseEnd,
      project: project,
      rate: project.hourlyRate,
      projectName: project.name,
      invoiceId: null,
    );

    await addTimeEntry(entry: newEntry, tasks: tasks);
    notifyListeners();
  }

  Future<void> refreshProjects() async {
    try {
      _isLoading = true;
      notifyListeners();
      final projectService = await ProjectService.create();
      final response = await projectService.getProjects();
      _projects = response.projects;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _timeEntries = [];
    _projects = [];
    _invoices = [];
    _error = null;
    _isClockedIn = false;
    _isPaused = false;
    _clockInTime = null;
    _pauseTime = null;
    _elapsed = Duration.zero;
    _accumulated = Duration.zero;
    _currentEarnings = 0.0;
    _currentProject = null;
    _timer?.cancel();
    _timer = null;
    _showUninvoicedOnly = false;

    notifyListeners();
  }

  void setProjectFilter(Project? project) {
    _selectedProjectFilter = project;
    notifyListeners();
  }

  List<TimeEntry> getSortedEntries() {
    var filteredEntries = _timeEntries;

    if (_showUninvoicedOnly) {
      filteredEntries =
          filteredEntries.where((entry) => entry.invoiceId == null).toList();
    }

    if (_selectedProjectFilter != null) {
      filteredEntries = filteredEntries
          .where((entry) => entry.project.id == _selectedProjectFilter!.id)
          .toList();
    }

    filteredEntries.sort((a, b) {
      return b.date.compareTo(a.date) != 0
          ? b.date.compareTo(a.date)
          : b.startTime.compareTo(a.startTime);
    });

    return filteredEntries;
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  List<TimeEntry> _applyDateFilter(List<TimeEntry> entries) {
    if (_startDate == null && _endDate == null) {
      return entries;
    }

    return entries.where((entry) {
      bool afterStart = true;
      bool beforeEnd = true;

      if (_startDate != null) {
        afterStart = entry.date.isAtSameMomentAs(_startDate!) ||
            entry.date.isAfter(_startDate!);
      }
      if (_endDate != null) {
        beforeEnd = entry.date.isAtSameMomentAs(_endDate!) ||
            entry.date.isBefore(_endDate!);
      }
      return afterStart && beforeEnd;
    }).toList();
  }

  double get totalEarnings {
    List<TimeEntry> filteredEntries = _applyDateFilter(_timeEntries);
    return filteredEntries.fold(0.0, (sum, entry) => sum + entry.totalEarnings);
  }

  double get totalHoursLogged {
    List<TimeEntry> filteredEntries = _applyDateFilter(_timeEntries);
    return filteredEntries.fold(0.0, (sum, entry) => sum + entry.billableHours);
  }

  List<TimeEntry> getUninvoicedEntries() {
    return _timeEntries.where((entry) => entry.invoiceId == null).toList();
  }

  Future<void> refreshInvoices() async {
    try {
      _isLoading = true;
      notifyListeners();
      final loadedInvoices = await _invoiceService.getInvoices();
      _invoices = loadedInvoices;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Invoice> generateInvoice({
    required String invoiceNumber,
    List<String>? projectIds,
  }) async {
    final uninvoiced = getUninvoicedEntries();
    if (uninvoiced.isEmpty) {
      throw Exception('No un-invoiced entries available.');
    }

    final targetEntries = (projectIds == null || projectIds.isEmpty)
        ? uninvoiced
        : uninvoiced
            .where((entry) => projectIds.contains(entry.project.id))
            .toList();

    if (targetEntries.isEmpty) {
      throw Exception(
        'No un-invoiced entries available for the selected project(s).',
      );
    }

    final totalAmount = targetEntries.fold<double>(
      0.0,
      (sum, entry) => sum + entry.totalEarnings,
    );

    final invoiceId = await _invoiceService.createInvoice(
      invoiceNumber: invoiceNumber,
      totalAmount: totalAmount,
    );

    final entryIds = targetEntries
        .where((entry) => entry.id != null && entry.id!.isNotEmpty)
        .map((entry) => entry.id!)
        .toList();

    await _timeEntryService.updateTimeEntriesInvoiceId(
      timeEntryIds: entryIds,
      invoiceId: invoiceId,
    );

    await refreshTimeEntries();
    await refreshInvoices();

    final newInvoice =
        _invoices.firstWhere((inv) => inv.id == invoiceId, orElse: () {
      throw Exception('Invoice not found after creation.');
    });

    return newInvoice;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> refreshClients() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Initialize with eLmpty list if not authenticated
      _clients = await _clientService.getClients();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _clients = []; // Ensure clients is never null
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addClient(Client client) async {
    try {
      final response = await Supabase.instance.client
          .from('clients')
          .insert(client.toJson())
          .select('*, contact(*), address(*)')
          .single();

      final newClient = Client.fromJson(response as Map<String, dynamic>);
      _clients.add(newClient);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateClient(Client client) async {
    try {
      final response = await Supabase.instance.client
          .from('clients')
          .update(client.toJson())
          .eq('id', client.id ?? '')
          .select('*, contact(*), address(*)')
          .single();

      final updatedClient = Client.fromJson(response as Map<String, dynamic>);
      final index = _clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        _clients[index] = updatedClient;
        notifyListeners();
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> loadContacts() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No authenticated user found');
    }

    final response = await Supabase.instance.client
        .from('contacts')
        .select()
        .eq('user_id', userId)
        .order('name');

    _contacts = response.map((json) => Contact.fromJson(json)).toList();
    notifyListeners();
  }

  Future<void> loadAddresses() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No authenticated user found');
    }

    final response = await Supabase.instance.client
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .order('street_1');

    _addresses = response.map((json) => Address.fromJson(json)).toList();
    notifyListeners();
  }

  Future<Contact> addContact(Contact contact) async {
    try {
      final response = await Supabase.instance.client
          .from('contacts')
          .insert(contact.toJson())
          .select()
          .single();

      final newContact = Contact.fromJson(response);
      _contacts.add(newContact);
      notifyListeners();
      return newContact;
    } catch (e) {
      throw e;
    }
  }

  Future<Address> addAddress(Address address) async {
    try {
      final response = await Supabase.instance.client
          .from('addresses')
          .insert(address.toJson())
          .select()
          .single();

      final newAddress = Address.fromJson(response);
      _addresses.add(newAddress);
      notifyListeners();
      return newAddress;
    } catch (e) {
      throw e;
    }
  }

  Future<Contact> updateContact(Contact contact) async {
    try {
      final response = await Supabase.instance.client
          .from('contacts')
          .update(contact.toJson())
          .eq('id', contact.id)
          .select()
          .single();

      final updatedContact = Contact.fromJson(response);
      final index = _contacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _contacts[index] = updatedContact;
        notifyListeners();
      }
      return updatedContact;
    } catch (e) {
      throw Exception('Failed to update contact: $e');
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await Supabase.instance.client
          .from('contacts')
          .delete()
          .eq('id', contactId);

      _contacts.removeWhere((contact) => contact.id == contactId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete contact: $e');
    }
  }

  Future<Address> updateAddress(Address address) async {
    try {
      final response = await Supabase.instance.client
          .from('addresses')
          .update(address.toJson())
          .eq('id', address.id)
          .select()
          .single();

      final updatedAddress = Address.fromJson(response);
      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
        notifyListeners();
      }
      return updatedAddress;
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await Supabase.instance.client
          .from('addresses')
          .delete()
          .eq('id', addressId);

      _addresses.removeWhere((address) => address.id == addressId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }
}
