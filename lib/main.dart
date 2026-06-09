import 'package:flutter/material.dart';
import 'package:planning_rev/pages/reglages.dart';
import 'package:planning_rev/pages/agenda.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'agenda_revision/state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/rappel.dart';
import 'pages/statistiques.dart';
import 'agenda_revision/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/notificationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await NotificationService.init();
  await Permission.notification.request();
  await Permission.scheduleExactAlarm.request();
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
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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

  final _screens = [
    AgendaPage(title: 'Agenda'),
    RappelsScreen(),
    StatsScreen(),
    ReglagesScreen(),
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