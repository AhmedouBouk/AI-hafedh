import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/schedule_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../widgets/common/refresh_indicator.dart';
import '../widgets/common/notification_handler.dart';

class EmploiPage extends StatefulWidget {
  const EmploiPage({super.key});

  @override
  State<EmploiPage> createState() => _EmploiPageState();
}

class _EmploiPageState extends State<EmploiPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;
  int _currentWeek = 1;

  final ApiService _apiService = ApiService();
  ScheduleMetadata? _metadata;
  List<ScheduleSession>? _sessions;

  // Enhanced color scheme
  static const MaterialColor primarySwatch = Colors.blue;
  static const Color accentColor = Color(0xFF2962FF);
  static const Color surfaceColor = Color(0xFFF5F5F5);
  static const Color headerColor = Color(0xFFE8EAF6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      if (ApiConfig.debugMode) {
        print('Loading data for week $_currentWeek');
      }

      // Load sessions for the current week
      final sessions = await _apiService.getScheduleSessions(_currentWeek);

      if (ApiConfig.debugMode) {
        print('Loaded ${sessions.length} sessions');
        print('Sessions by day:');
        final days = ['LUN', 'MAR', 'MER', 'JEU', 'VEN'];
        for (final day in days) {
          final daySessions = sessions.where((s) => s.day == day).toList();
          print('$day: ${daySessions.length} sessions');
        }
      }

      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (ApiConfig.debugMode) {
        print('Error loading data: $e');
      }
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<ScheduleSession> _getSessionsForDay(String day) {
    if (_sessions == null) {
      if (ApiConfig.debugMode) {
        print('No sessions available for $day');
      }
      return [];
    }

    final daySessions = _sessions!.where((session) => session.day == day).toList()
      ..sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

    if (ApiConfig.debugMode) {
      print('Found ${daySessions.length} sessions for $day');
      daySessions.forEach((s) => print('${s.code} at slot ${s.timeSlot}'));
    }

    return daySessions;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationHandler(
      onUpdate: _loadData,
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: primarySwatch,
            accentColor: accentColor,
          ),
        ),
        child: Scaffold(
          backgroundColor: surfaceColor,
          body: AutoRefreshIndicator(
            onRefresh: _loadData,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Emploi du temps - Semaine $_currentWeek',
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () {
                      if (_currentWeek > 1) {
                        setState(() {
                          _currentWeek--;
                          _loadData();
                        });
                      }
                    },
                  ),
                  DropdownButton<int>(
                    value: _currentWeek,
                    isDense: true,
                    items: List.generate(
                      15,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('S${index + 1}'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _currentWeek = value;
                          _loadData();
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 20),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () {
                      if (_currentWeek < 15) {
                        setState(() {
                          _currentWeek++;
                          _loadData();
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildSliverAppBar(),
            ],
            body: Column(
              children: [
                _buildTabBar(),
                Expanded(child: _buildTabBarView()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    if (_metadata == null) return const SliverToBoxAdapter();

    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A237E),
                Color(0xFF3949AB),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  _buildSemesterInfo(),
                  SizedBox(height: 12),
                  _buildDateRange(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoChip(
          label: _metadata?.semester ?? 'S3',
          prefix: 'Semestre',
          icon: Icons.school,
        ),
        _buildInfoChip(
          label: _metadata?.week.toString() ?? '12',
          prefix: 'Semaine',
          icon: Icons.date_range,
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required String label,
    required String prefix,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                prefix,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRange() {
    final startDate = _metadata?.startDate;
    final endDate = _metadata?.endDate;

    if (startDate == null || endDate == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${startDate.day}/${startDate.month}/${startDate.year}',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.arrow_forward, size: 16, color: Colors.white70),
          ),
          Text(
            '${endDate.day}/${endDate.month}/${endDate.year}',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: surfaceColor,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: 'LUN'),
          Tab(text: 'MAR'),
          Tab(text: 'MER'),
          Tab(text: 'JEU'),
          Tab(text: 'VEN'),
        ],
        labelColor: accentColor,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
        indicatorColor: accentColor,
        indicatorWeight: 3,
      ),
    );
  }

  Widget _buildTabBarView() {
    final days = ['LUN', 'MAR', 'MER', 'JEU', 'VEN'];
    
    return TabBarView(
      controller: _tabController,
      children: days.map((day) {
        final sessions = _getSessionsForDay(day);
        if (ApiConfig.debugMode) {
          print('Building tab for $day with ${sessions.length} sessions');
        }
        return _DaySchedule(day: day, sessions: sessions);
      }).toList(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _DaySchedule extends StatelessWidget {
  final String day;
  final List<ScheduleSession> sessions;

  const _DaySchedule({
    required this.day,
    required this.sessions,
  });

  String _getTimeSlot(int slot) {
    switch (slot) {
      case 1:
        return '8:30 - 10:00';
      case 2:
        return '10:15 - 11:45';
      case 3:
        return '12:00 - 13:30';
      case 4:
        return '13:45 - 15:15';
      case 5:
        return '15:30 - 17:00';
      case 6:
        return '17:15 - 18:45';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building _DaySchedule for day: $day with ${sessions.length} sessions');
    if (sessions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No sessions scheduled',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        print('Building session for $day: ${session.code} at time slot ${session.timeSlot}');
        final timeSlot = _getTimeSlot(session.timeSlot);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildTimeHeader(timeSlot, context),
              _buildSessionContent(session, context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeHeader(String timeSlot, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _EmploiPageState.headerColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.access_time_rounded,
              size: 16,
              color: _EmploiPageState.accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            timeSlot,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionContent(ScheduleSession session, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (session.code.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _EmploiPageState.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session.code,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _EmploiPageState.accentColor,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  session.type,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            session.name,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (session.room.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.room_outlined,
                          size: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      session.room,
                      style: GoogleFonts.inter(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              if (session.professor.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.person_outline,
                          size: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      session.professor,
                      style: GoogleFonts.inter(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}