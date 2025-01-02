import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmploiPage extends StatefulWidget {
  const EmploiPage({super.key});

  @override
  State<EmploiPage> createState() => _EmploiPageState();
}

class _DaySchedule extends StatelessWidget {
  final String day;
  final List<CourseData> courses;
  final bool compactMode;

  const _DaySchedule({
    required this.day,
    required this.courses,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final timeSlot = _getTimeSlot(index);

        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            onTap: () {/* Show course details */},
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                _buildTimeHeader(timeSlot),
                if (!course.isEmpty) _buildCourseContent(course),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeHeader(String timeSlot) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _EmploiPageState.headerColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
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
          SizedBox(width: 12),
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

  Widget _buildCourseContent(CourseData course) {
    final typeColor = _EmploiPageState.typeColors[course.type] ?? Colors.grey[100]!;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (course.code.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _EmploiPageState.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    course.code,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _EmploiPageState.accentColor,
                    ),
                  ),
                ),
                SizedBox(width: 12),
              ],
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  course.type,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (course.isOnline) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_rounded, size: 14, color: Colors.green[700]),
                      SizedBox(width: 4),
                      Text(
                        'En ligne',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (!compactMode && course.name.isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              course.name,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
          SizedBox(height: 12),
          Row(
            children: [
              if (course.room.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.room_outlined, 
                    size: 16, 
                    color: Colors.grey[700]
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  course.room,
                  style: GoogleFonts.inter(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 16),
              ],
              if (course.professor.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.person_outline_rounded, 
                    size: 16, 
                    color: Colors.grey[700]
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  course.professor,
                  style: GoogleFonts.inter(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeSlot(int index) {
    switch (index) {
      case 0:
        return '08:00 - 09:30';
      case 1:
        return '09:45 - 11:15';
      case 2:
        return '11:30 - 13:00';
      case 3:
        return '15:10 - 16:40';
      default:
        return '';
    }
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

class CourseData {
  final String code;
  final String type;
  final String room;
  final String name;
  final String professor;
  final bool isOnline;

  const CourseData(
    this.code,
    this.type,
    this.room,
    this.name,
    this.professor, {
    this.isOnline = false,
  });

  bool get isEmpty =>
      code.isEmpty &&
      type.isEmpty &&
      room.isEmpty &&
      name.isEmpty &&
      professor.isEmpty;

  Color getTypeColor() {
    return _EmploiPageState.typeColors[type] ?? Colors.white;
  }
}

class _EmploiPageState extends State<EmploiPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  bool _compactMode = false;

  // Enhanced color scheme
  static const MaterialColor primarySwatch = Colors.blue;
  static const Color accentColor = Color(0xFF2962FF);
  static const Color surfaceColor = Color(0xFFF8F9FA);
  static const Color headerColor = Color(0xFFE8EAF6);

  // Simplified course type colors
  static final Map<String, Color> typeColors = {
    'HE': Color(0xFFF1F8E9),
    'Devoir': Color(0xFFFFEBEE),
    'IRT': Color(0xFFE3F2FD),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: primarySwatch,
          accentColor: accentColor,
        ),
      ),
      child: Scaffold(
        backgroundColor: surfaceColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(),
            _buildSliverFilters(),
          ],
          body: Column(
            children: [
              _buildTabBar(),
              Expanded(child: _buildTabBarView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
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
                  Text(
                    'Emploi du Temps',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildSemesterInfo(),
                  SizedBox(height: 12),
                  _buildDateRange(),
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
          label: 'S3',
          prefix: 'Semestre',
          icon: Icons.school,
        ),
        _buildInfoChip(
          label: '12',
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
            '06/01/2025',
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
            '11/01/2025',
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

  Widget _buildSliverFilters() {
    final filters = ['All', 'HE', 'Devoir', 'IRT'];

    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 70,
        maxHeight: 70,
        child: Container(
          color: surfaceColor,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = _selectedFilter == filter;

              return Padding(
                padding: EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    filter,
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedFilter = filter);
                  },
                  backgroundColor: isSelected
                      ? accentColor
                      : typeColors[filter] ?? Colors.grey[100],
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),
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
    return TabBarView(
      controller: _tabController,
      children: [
        _DaySchedule(
          day: 'Lundi',
          courses: _getCoursesForDay('Lundi'),
          compactMode: _compactMode,
        ),
        _DaySchedule(
          day: 'Mardi',
          courses: _getCoursesForDay('Mardi'),
          compactMode: _compactMode,
        ),
        _DaySchedule(
          day: 'Mercredi',
          courses: _getCoursesForDay('Mercredi'),
          compactMode: _compactMode,
        ),
        _DaySchedule(
          day: 'Jeudi',
          courses: _getCoursesForDay('Jeudi'),
          compactMode: _compactMode,
        ),
        _DaySchedule(
          day: 'Vendredi',
          courses: _getCoursesForDay('Vendredi'),
          compactMode: _compactMode,
        ),
      ],
    );
  }

  List<CourseData> _getCoursesForDay(String day) {
    switch (day) {
      case 'Lundi':
        return [
          CourseData('IRT31', 'IRT', '104', 'Développement JEE', 'Aboubécrine'),
          CourseData('IRT31', 'IRT', '104', 'Développement JEE', 'Aboubécrine'),
          CourseData('IRT33', 'IRT', '104', 'Théorie des langages et compilation', 'Hafedh'),
          CourseData('IRT37', 'IRT', '104', 'Réseaux d\'opérateurs', 'El Aoun'),
        ];

      case 'Mardi':
        return [
          CourseData('', 'HE', '', '', ''),
          CourseData('', 'HE', '', '', ''),
          CourseData('', 'HE', '', '', ''),
          CourseData('IRT31', 'Devoir', '104', 'Développement JEE', 'Aboubécrine'),
        ];

      case 'Mercredi':
        return [
          CourseData('', 'HE', '', '', ''),
          CourseData('', 'HE', '', '', ''),
          CourseData('', 'HE', '', '', ''),
          CourseData('', 'IRT', '', 'Enseignement militaire', ''),
        ];

      case 'Jeudi':
        return [
          CourseData('IRT32', 'IRT', '104', 'Intelligence artificielle', 'Hafedh'),
          CourseData('IRT35', 'IRT', 'Lab Electro', 'Architecture des ordinateurs', 'Sass'),
          CourseData('IRT35', 'IRT', 'Lab Electro', 'Architecture des ordinateurs', 'Sass'),
          CourseData('IRT38', 'IRT', '', 'IoT', 'Elhacen', isOnline: true),
        ];

      case 'Vendredi':
        return [
          CourseData('', 'HE', '', '', ''),
          CourseData('IRT33', 'Devoir', '104', 'Théorie des langages et compilation', 'Hafedh'),
          CourseData('IRT35', 'Devoir', '104', 'Architecture des ordinateurs', 'Sass'),
          CourseData('', '', '', '', ''),
        ];

      default:
        return List.generate(4, (_) => CourseData('', '', '', '', ''));
    }
  }
}