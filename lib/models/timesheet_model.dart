import 'package:flutter/material.dart';
import 'dart:async';
import 'project.dart';
import 'time_entry.dart';

class TimesheetModel extends ChangeNotifier {
  final List<TimeEntry> _timeEntries = [];
  final List<Project> _projects = [];

  bool _isClockedIn = false;
  bool _isPaused = false;
  DateTime? _clockInTime;
  Duration _elapsed = Duration.zero;
  Duration _accumulated = Duration.zero;
  double _currentEarnings = 0.0;
  Project? _currentProject;

  Timer? _timer;

  List<TimeEntry> get timeEntries => _timeEntries;
  List<Project> get projects => _projects;

  bool get isClockedIn => _isClockedIn;
  bool get isPaused => _isPaused;
  DateTime? get clockInTime => _clockInTime;
  Duration get elapsed => _elapsed;
  double get currentEarnings => _currentEarnings;
  Project? get currentProject => _currentProject;

  void addTimeEntry(TimeEntry entry) {
    _timeEntries.add(entry);
    notifyListeners();
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
    _accumulated += DateTime.now().difference(_clockInTime!);
    _timer?.cancel();
    notifyListeners();
  }

  void resumeClock() {
    if (!_isClockedIn || !_isPaused || _currentProject == null) return;

    _isPaused = false;
    _clockInTime = DateTime.now();

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

  void clockOut() {
    if (!_isClockedIn || _currentProject == null || _clockInTime == null) return;

    final clockOutTime = DateTime.now();

    _isClockedIn = false;
    _isPaused = false;
    _timer?.cancel();

    Duration totalElapsed = _accumulated;
    if (!_isPaused) {
      totalElapsed += clockOutTime.difference(_clockInTime!);
    }

    final newEntry = TimeEntry(
      id: "",
      date: DateTime(
        _clockInTime!.year, 
        _clockInTime!.month,
         _clockInTime!.day),
      startTime: _clockInTime!,
      endTime: clockOutTime,
      project: _currentProject!,
      rate: _currentProject!.hourlyRate,
      projectName: _currentProject!.name,
    );

    _timeEntries.add(newEntry);

    _elapsed = Duration.zero;
    _accumulated = Duration.zero;
    _currentEarnings = 0.0;
    _clockInTime = null;
    _currentProject = null;

    notifyListeners();
  }

  void addManualTimeEntry(DateTime date, TimeOfDay startTime, TimeOfDay endTime, Project project) {
    final preciseStart = DateTime (
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
      0, // manual entries have to be 0 because TimePicker sucks
    );
    final preciseEnd = DateTime (
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
      0, // time picker sucks
    );


    final newEntry = TimeEntry (
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
      projectName: project.name
    );
    
    _timeEntries.add(newEntry);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
