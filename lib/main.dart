import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'styles.dart';
import 'package:provider/provider.dart';
import 'models/timesheet_model.dart';
import 'pages/add_time_entry_page.dart';
import 'pages/project_list_page.dart';
import 'pages/dashboard_tab.dart';
import 'pages/entries_page.dart';
import 'pages/auth_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = '{{Supabase_url}}';
  const supabaseAnonKey = '{{Supabase_anon_key}}';

  if (kIsWeb) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  } else {
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      throw Exception(
          'Missing Supabase environment variables. Please check your .env file.');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => TimesheetModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();

    _currentUser = Supabase.instance.client.auth.currentUser;

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {
        _currentUser = data.session?.user;
      });
    });
  }
  @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Timesheet Tracker',
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        home: _currentUser == null
              ? const AuthPage()
              : const MainNavigation(),
      );
    }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  MainNavigationState createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardTab(),
      const ProjectListPage(),
      const EntriesPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Entries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 2)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTimeEntryPage(),
                  ),
                );
              },
              tooltip: 'Add Time Entry',
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Settings Page',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Sign out via our AuthService
                await AuthService.signOut();
                // Once signed out, the onAuthStateChange subscription
                // in _MyAppState will set _currentUser to null,
                // which sends the user back to AuthPage.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}


