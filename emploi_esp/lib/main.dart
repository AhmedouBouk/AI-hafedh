import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:ionicons/ionicons.dart';
import './screens/emploi_page.dart';
import 'bdd_page.dart';
import 'plan_page.dart';
import 'bilan_page.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  if (receivedAction.buttonKeyPressed == "VIEW_UPDATES") {
    debugPrint(
        'Notification action received: ${receivedAction.buttonKeyPressed}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Schedule Updates',
        channelDescription: 'Notifications for schedule changes',
        defaultColor: Colors.teal,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ],
  );

  await AwesomeNotifications().setListeners(
    onActionReceivedMethod: onActionReceivedMethod,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

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
    BDDPage(),
    PlanPage(),
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
    if (_currentIndex > _previousIndex) return 0.1;
    if (_currentIndex < _previousIndex) return -0.1;
    return 0.0;
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
            label: 'Schedule',
            color: const Color(0xFF2962FF),
          ),
          _buildNavItem(
            icon: Ionicons.server_outline,
            activeIcon: Ionicons.server,
            label: 'Database',
            color: const Color(0xFF00B0FF),
          ),
          _buildNavItem(
            icon: Ionicons.map_outline,
            activeIcon: Ionicons.map,
            label: 'Map',
            color: const Color(0xFF00C853),
          ),
          _buildNavItem(
            icon: Ionicons.stats_chart_outline,
            activeIcon: Ionicons.stats_chart,
            label: 'Analytics',
            color: const Color(0xFFFF6D00),
          ),
        ],
      ),
    );
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
}
