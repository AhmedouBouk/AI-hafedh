import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shimmer/shimmer.dart';
import '../models/bilan_model.dart';
import '../services/api_service.dart';

class BilanPage extends StatefulWidget {
  const BilanPage({Key? key}) : super(key: key);

  @override
  _BilanPageState createState() => _BilanPageState();
}

class _BilanPageState extends State<BilanPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  BilanSemester? _bilanData;
  String? _error;
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    _loadBilanData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBilanData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bilanData = await _apiService.getBilanData();
      setState(() {
        _bilanData = bilanData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('API Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadBilanData,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Progression des Cours',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_bilanData == null || _bilanData!.courses.isEmpty) {
      return _buildEmptyState();
    }

    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            _buildOverallProgress(),
            const SizedBox(height: 24),
            _buildProgressChart(),
            const SizedBox(height: 24),
            _buildCoursesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _error!.contains('FormatException')
                ? 'Il y a des cours invalides dans la base de données'
                : 'Erreur: $_error',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadBilanData,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun cours disponible',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgress() {
    final progress = _bilanData!.averageProgress / 100;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Progression Globale',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 12.0,
              animation: true,
              animationDuration: 1500,
              percent: progress,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_bilanData!.averageProgress).toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getTotalHours(),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: _getProgressColor(_bilanData!.averageProgress),
              backgroundColor: _getProgressColor(_bilanData!.averageProgress).withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Progression par Type',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildProgressBar('CM', _getAverageProgress('CM')),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressBar('TD', _getAverageProgress('TD')),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressBar('TP', _getAverageProgress('TP')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress) {
    return Column(
      children: [
        Container(
          height: 150,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.withOpacity(0.1),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 150 * (progress / 100),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _getProgressColor(progress),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${progress.toStringAsFixed(1)}%',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: _getProgressColor(progress),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  double _getAverageProgress(String type) {
    if (_bilanData == null || _bilanData!.courses.isEmpty) return 0;
    
    double total = 0;
    for (var course in _bilanData!.courses) {
      switch (type) {
        case 'CM':
          total += course.cmProgress;
          break;
        case 'TD':
          total += course.tdProgress;
          break;
        case 'TP':
          total += course.tpProgress;
          break;
      }
    }
    return total / _bilanData!.courses.length;
  }

  Widget _buildCoursesList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails des Cours',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._bilanData!.courses.map((course) => _buildCourseCard(course)),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(BilanData course) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          course.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Code: ${course.code} | Crédits: ${course.credits}',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        trailing: CircularPercentIndicator(
          radius: 25.0,
          lineWidth: 4.0,
          percent: course.totalProgress / 100,
          center: Text(
            '${course.totalProgress.toStringAsFixed(0)}%',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          progressColor: _getProgressColor(course.totalProgress),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProgressRow('CM', course.cmCompleted, course.cmHours, course.cmProgress),
                const SizedBox(height: 8),
                _buildProgressRow('TD', course.tdCompleted, course.tdHours, course.tdProgress),
                const SizedBox(height: 8),
                _buildProgressRow('TP', course.tpCompleted, course.tpHours, course.tpProgress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, double completed, double total, double progress) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: _getProgressColor(progress).withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(progress)),
              ),
              const SizedBox(height: 4),
              Text(
                '$completed/$total heures (${progress.toStringAsFixed(1)}%)',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 90) return Colors.green;
    if (progress >= 70) return Colors.lightGreen;
    if (progress >= 50) return Colors.orange;
    if (progress >= 30) return Colors.deepOrange;
    return Colors.red;
  }

  String _getTotalHours() {
    if (_bilanData == null) return '0/0';
    
    double totalPlanned = 0;
    double totalCompleted = 0;
    
    for (var course in _bilanData!.courses) {
      totalPlanned += course.totalPlannedHours;
      totalCompleted += course.totalCompletedHours;
    }
    
    return '${totalCompleted.toStringAsFixed(1)}/${totalPlanned.toStringAsFixed(1)} h';
  }
}
