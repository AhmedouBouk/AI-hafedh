import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:ionicons/ionicons.dart';
import 'emploi_page.dart';
import 'bdd_page.dart';
import 'plan_page.dart';
import 'bilan_page.dart';

void main() {
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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
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
          
          // Page content with animation
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

  double _getSlideDirection() {
    if (_currentIndex > _previousIndex) {
      return 0.1;
    } else if (_currentIndex < _previousIndex) {
      return -0.1;
    }
    return 0.0;
  }

  int _previousIndex = 0;

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

// Custom page transition
class CustomPageRoute extends PageRouteBuilder {
  final Widget page;
  final bool forward;

  CustomPageRoute({required this.page, this.forward = true})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(
              begin: forward ? begin : -begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}