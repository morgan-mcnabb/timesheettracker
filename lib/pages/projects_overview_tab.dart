import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timesheet_model.dart';
import '../models/project.dart';
import '../widgets/project_card.dart';

class ProjectsOverviewTab extends StatelessWidget {
  const ProjectsOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);
    final List<Project> projects = timesheet.projects;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Map<String, Map<String, double>> projectMetrics = {};
    for (var project in projects) {
      projectMetrics[project.name] = {
        'hours': 0.0,
        'earnings': 0.0,
      };
    }
    for (var entry in timesheet.timeEntries) {
      if (projectMetrics.containsKey(entry.project?.name)) {
        projectMetrics[entry.project?.name]!['hours'] =
            projectMetrics[entry.project?.name]!['hours']! +
                entry.billableHours;
        projectMetrics[entry.project?.name]!['earnings'] =
            projectMetrics[entry.project?.name]!['earnings']! +
                entry.totalEarnings;
      }
    }

    if (projects.isEmpty) {
      return const Center(
        child: Text(
          'No projects available.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    const double standardPadding = 16.0;

    return Padding(
      padding: const EdgeInsets.all(standardPadding),
      child: GridView.builder(
        itemCount: projects.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          mainAxisSpacing: standardPadding,
          crossAxisSpacing: standardPadding,
          childAspectRatio: 3 / 2,
        ),
        itemBuilder: (context, index) {
          final project = projects[index];
          final metrics = projectMetrics[project.name]!;

          return ProjectCard(
            project: project,
            hoursLogged: metrics['hours']!,
            earnings: metrics['earnings']!,
          );
        },
      ),
    );
  }
}
