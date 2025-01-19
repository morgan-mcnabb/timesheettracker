import 'package:flutter/material.dart';
import 'package:timesheettracker/services/project_service.dart';
import 'dart:async';
import 'project.dart';
import 'time_entry.dart';
import 'package:timesheettracker/services/time_entry_service.dart';

class TimesheetModel extends ChangeNotifier {
  List<TimeEntry> _timeEntries = [];
  List<Project> _projects = [];

  bool _isClockedIn = false;
  bool _isPaused = false;
  DateTime? _clockInTime;
  DateTime? _pauseTime;
  Duration _elapsed = Duration.zero;
  Duration _accumulated = Duration.zero;
  double _currentEarnings = 0.0;
  Project? _currentProject;

  Timer? _timer;

  bool _isLoading = false;

  String? _error;

  late final TimeEntryService _timeEntryService;

  List<TimeEntry> get timeEntries => _timeEntries;
  List<Project> get projects => _projects;

  bool get isClockedIn => _isClockedIn;
  bool get isPaused => _isPaused;
  DateTime? get clockInTime => _clockInTime;
  Duration get elapsed => _elapsed;
  double get currentEarnings => _currentEarnings;
  Project? get currentProject => _currentProject;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;

  TimesheetModel() {
    _initServices();
  }

  Future<void> _initServices() async {
    _timeEntryService = await TimeEntryService.create();
    refreshProjects();
    refreshTimeEntries();
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

  Future<void> addTimeEntry(TimeEntry entry) async {
    try {
      await _timeEntryService.createTimeEntry(entry);
      await refreshTimeEntries();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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

  Future<void> clockOut() async {
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
    );

    await addTimeEntry(newEntry);

    _elapsed = Duration.zero;
    _accumulated = Duration.zero;
    _currentEarnings = 0.0;
    _clockInTime = null;
    _currentProject = null;
    _pauseTime = null;

    notifyListeners();
  }

  void addManualTimeEntry(
      DateTime date, TimeOfDay startTime, TimeOfDay endTime, Project project) {
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
        id: "",
        date: DateTime(
          preciseStart.year,
          preciseStart.month,
          preciseStart.day,
        ),
        startTime: preciseStart,
        endTime: preciseEnd,
        project: project,
        rate: project.hourlyRate,
        projectName: project.name);

    _timeEntries.add(newEntry);
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
