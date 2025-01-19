import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:ionicons/ionicons.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:workmanager/workmanager.dart';
import './screens/emploi_page.dart';
import 'screens/bilan_page.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Future.delayed(Duration(seconds: 2));
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Colors.teal,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      ),
    ],
  );

  // Initialize background tasks
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    "updateCheck",
    "updateCheckTask",
    frequency: Duration(minutes: 1),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modern Schedule',
      theme: _buildTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme() {
    final baseTheme = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2962FF),
        brightness: Brightness.light,
      ),
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  int _previousIndex = 0;

  final List<Widget> _pages = [
    EmploiPage(),
    BilanPage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _getSlideDirection() {
    if (_currentIndex > _previousIndex) {
      return 0.1;
    } else if (_currentIndex < _previousIndex) {
      return -0.1;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
          ),
          _pages[_currentIndex]
              .animate(controller: _animationController)
              .fadeIn(duration: 300.ms)
              .slideX(
                begin: _getSlideDirection(),
                duration: 300.ms,
                curve: Curves.easeOutCubic,
              ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _previousIndex = _currentIndex;
            _currentIndex = index;
            _animationController.forward(from: 0);
          });
        },
        items: [
          _buildNavItem(
            icon: Ionicons.calendar_outline,
            activeIcon: Ionicons.calendar,
            label: 'Emploi',
            color: const Color(0xFF2962FF),
          ),
          _buildNavItem(
            icon: Ionicons.stats_chart_outline,
            activeIcon: Ionicons.stats_chart,
            label: 'Bilan',
            color: const Color(0xFFFF6D00),
          ),
        ],
      ),
    );
  }

  SalomonBottomBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color color,
  }) {
    return SalomonBottomBarItem(
      icon: Icon(icon),
      activeIcon: Icon(activeIcon),
      title: Text(
        label,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      selectedColor: color,
      unselectedColor: Colors.grey[600],
    );
  }
}
