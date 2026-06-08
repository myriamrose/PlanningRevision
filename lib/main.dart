import 'package:flutter/material.dart';
import 'package:planning_rev/pages/agenda.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:agenda_revision/state.dart';
import 'package:agenda_revision/theme.dart';
import 'package:agenda_revision/screens/agenda.dart';
import 'package:agenda_revision/screens/rappels.dart';
import 'package:agenda_revision/screens/stats.dart';
import 'package:agenda_revision/screens/reglages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const AgendaRevisionApp(),
    ),
  );
}

class AgendaRevisionApp extends StatelessWidget {
  const AgendaRevisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Révision',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  static const _screens = [
    AgendaScreen(),
    RappelsScreen(),
    StatsScreen(),
    ReglagésScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Agenda'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Rappels'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Réglages'),
          ],
        ),
      ),
    );
  }
}