import 'package:flutter/material.dart';
import 'summary_tab.dart';
import 'projects_overview_tab.dart';
import 'recent_entries_tab.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: Colors.deepPurple,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Summary', icon: Icon(Icons.dashboard)),
              Tab(text: 'Projects', icon: Icon(Icons.business_center)),
              Tab(text: 'Recent', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SummaryTab(),
            ProjectsOverviewTab(),
            RecentEntriesTab(),
          ],
        ),
      ),
    );
  }
}
