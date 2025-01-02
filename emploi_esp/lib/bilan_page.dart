import 'package:flutter/material.dart';

class CourseProgress {
  final String codeEM;
  final String titre;
  final int creditsEM;
  final Map<String, int> planification;
  final Map<String, int> realisation;
  final Map<String, double> avancement;

  CourseProgress({
    required this.codeEM,
    required this.titre,
    required this.creditsEM,
    required this.planification,
    required this.realisation,
    required this.avancement,
  });
}

class BilanPage extends StatelessWidget {
  final List<CourseProgress> courses = [
    CourseProgress(
      codeEM: 'IRT31',
      titre: 'Développement JEE',
      creditsEM: 3,
      planification: {'CM': 6, 'TD': 6, 'TP': 12, 'Total': 24},
      realisation: {'CM': 4, 'TD': 3, 'TP': 9, 'Total': 16},
      avancement: {'CM': 0.67, 'TD': 0.50, 'TP': 0.75, 'Total': 0.67},
    ),
    CourseProgress(
      codeEM: 'IRT32',
      titre: 'Intelligence artificielle',
      creditsEM: 2,
      planification: {'CM': 5, 'TD': 5, 'TP': 6, 'Total': 16},
      realisation: {'CM': 3, 'TD': 5, 'TP': 1, 'Total': 9},
      avancement: {'CM': 0.60, 'TD': 1.00, 'TP': 0.17, 'Total': 0.56},
    ),
    CourseProgress(
      codeEM: 'IRT33',
      titre: 'Théorie des langages et compilation',
      creditsEM: 2,
      planification: {'CM': 5, 'TD': 5, 'TP': 6, 'Total': 16},
      realisation: {'CM': 3, 'TD': 3, 'TP': 2, 'Total': 8},
      avancement: {'CM': 0.60, 'TD': 0.60, 'TP': 0.33, 'Total': 0.50},
    ),
    // Add other courses...
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bilan d\'avancement'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Vue Globale'),
              Tab(text: 'Par Matière'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGlobalView(),
            _buildDetailedView(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalView() {
    final globalProgress = {
      'CM': 0.75,
      'TD': 0.63,
      'TP': 0.56,
      'Total': 0.64,
    };

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUpdateInfo(),
            SizedBox(height: 16),
            _buildGlobalProgressCard(globalProgress),
            SizedBox(height: 16),
            _buildGlobalStatsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedView() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) => _buildCourseCard(courses[index]),
    );
  }

  Widget _buildUpdateInfo() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.update, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Actualisé fin semaine 11',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalProgressCard(Map<String, double> globalProgress) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Avancement Global',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircularProgress('CM', globalProgress['CM']!),
                _buildCircularProgress('TD', globalProgress['TD']!),
                _buildCircularProgress('TP', globalProgress['TP']!),
                _buildCircularProgress('Total', globalProgress['Total']!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalStatsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques Globales',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildStatRow('Nombre total de séances planifiées', '168'),
            _buildStatRow('Nombre total de séances réalisées', '108'),
            _buildStatRow('Nombre de matières', '9'),
            _buildStatRow('Crédits total', '20'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(String label, double value) {
    final percentage = (value * 100).round();
    Color color = _getProgressColor(value);

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCourseCard(CourseProgress course) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                course.codeEM,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                course.titre,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${(course.avancement['Total']! * 100).round()}%',
                style: TextStyle(
                  color: _getProgressColor(course.avancement['Total']!),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProgressSection('CM', course),
                _buildProgressSection('TD', course),
                _buildProgressSection('TP', course),
                Divider(),
                _buildProgressSection('Total', course),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(String type, CourseProgress course) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              type,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${course.planification[type] ?? 0} séances prévues'),
                    Text('${course.realisation[type] ?? 0} réalisées'),
                    Text(
                      '${(course.avancement[type]! * 100).round()}%',
                      style: TextStyle(
                        color: _getProgressColor(course.avancement[type]!),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: course.avancement[type]!,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(course.avancement[type]!),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double value) {
    final percentage = value * 100;
    if (percentage >= 100) return Colors.green;
    if (percentage >= 75) return Colors.lightGreen;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}
