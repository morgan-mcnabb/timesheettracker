import 'package:flutter/material.dart';
import '../services/project_service.dart';
import 'dart:async';
import 'project.dart';
import 'time_entry.dart';
import '../services/time_entry_service.dart';
import '../services/invoice_service.dart';
import '../models/invoice.dart';
import '../services/task_service.dart'; 
import '../models/task.dart'; 


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

  late final TimeEntryService _timeEntryService;
  late final InvoiceService _invoiceService;
  late final TaskService _taskService;

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

  void setShowUninvoicedOnly(bool value){
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
    refreshProjects();
    refreshTimeEntries();
    refreshInvoices();
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

  Future<void> addTimeEntry({required TimeEntry entry, List<Task>? tasks}) async {
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
    if (!_isClockedIn || _currentProject == null || _clockInTime == null)
    {
      return;
    }
    final DateTime? clockOutTime;

    if(_isPaused && _pauseTime != null) {
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
      DateTime date, TimeOfDay startTime, TimeOfDay endTime, Project project, {List<Task>? tasks}) async {
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
        invoiceId: null,);

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

    if(_showUninvoicedOnly) {
      filteredEntries = filteredEntries.where((entry) => entry.invoiceId == null).toList();
    }

    if(_selectedProjectFilter != null) {
      filteredEntries = filteredEntries
        .where((entry) => entry.project.id == _selectedProjectFilter!.id)
        .toList();
    }

    filteredEntries.sort((a,b) {
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
    return filteredEntries.fold(
        0.0, (sum, entry) => sum + entry.totalEarnings);
  }

  double get totalHoursLogged {
    List<TimeEntry> filteredEntries = _applyDateFilter(_timeEntries);
    return filteredEntries.fold(
        0.0, (sum, entry) => sum + entry.billableHours);
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
}
