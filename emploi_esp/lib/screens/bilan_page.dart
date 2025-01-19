import 'package:flutter/material.dart';
import '../models/bilan_model.dart';
import '../services/api_service.dart';

class BilanPage extends StatefulWidget {
  const BilanPage({Key? key}) : super(key: key);

  @override
  State<BilanPage> createState() => _BilanPageState();
}

class _BilanPageState extends State<BilanPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  BilanSemester? _bilanData;

  @override
  void initState() {
    super.initState();
    _loadBilanData();
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
      appBar: AppBar(
        title: const Text('Bilan des Cours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBilanData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBilanData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!.contains('FormatException')
                  ? 'Il y a des cours invalides dans la base de données. Veuillez vérifier que tous les cours ont un code valide.'
                  : 'Error: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBilanData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_bilanData == null || _bilanData!.courses.isEmpty) {
      return const Center(
        child: Text('Aucune donnée disponible'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalProgress(),
              const SizedBox(height: 24),
              _buildProgressTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalProgress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Progression Moyenne',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_bilanData?.averageProgress.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(_bilanData?.averageProgress ?? 0),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.trending_up,
                  color: _getProgressColor(_bilanData?.averageProgress ?? 0),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Total des heures: ${_getTotalHours()}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _getTotalHours() {
    if (_bilanData == null) return '0/0';
    
    double totalPlanned = 0;
    double totalCompleted = 0;
    
    for (var course in _bilanData!.courses) {
      totalPlanned += course.totalPlannedHours;
      totalCompleted += course.totalCompletedHours;
    }
    
    return '${totalCompleted.toStringAsFixed(1)}/${totalPlanned.toStringAsFixed(1)} (${((totalCompleted/totalPlanned)*100).toStringAsFixed(1)}%)';
  }

  Color _getProgressColor(double progress) {
    if (progress >= 90) return Colors.green;
    if (progress >= 70) return Colors.lightGreen;
    if (progress >= 50) return Colors.orange;
    if (progress >= 30) return Colors.deepOrange;
    return Colors.red;
  }

  Widget _buildProgressTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Code')),
        DataColumn(label: Text('Title')),
        DataColumn(label: Text('Credits')),
        DataColumn(label: Text('CM')),
        DataColumn(label: Text('TD')),
        DataColumn(label: Text('TP')),
        DataColumn(label: Text('Total')),
      ],
      rows: _bilanData!.courses.map((course) {
        return DataRow(
          cells: [
            DataCell(Text(course.code)),
            DataCell(Text(course.title)),
            DataCell(Text(course.credits.toString())),
            DataCell(Text(
              '${course.cmCompleted.toStringAsFixed(1)}/${course.cmHours.toStringAsFixed(1)}\n${course.cmProgress.toStringAsFixed(1)}%',
              style: TextStyle(
                color: _getProgressColor(course.cmProgress),
                fontWeight: FontWeight.bold,
              ),
            )),
            DataCell(Text(
              '${course.tdCompleted.toStringAsFixed(1)}/${course.tdHours.toStringAsFixed(1)}\n${course.tdProgress.toStringAsFixed(1)}%',
              style: TextStyle(
                color: _getProgressColor(course.tdProgress),
                fontWeight: FontWeight.bold,
              ),
            )),
            DataCell(Text(
              '${course.tpCompleted.toStringAsFixed(1)}/${course.tpHours.toStringAsFixed(1)}\n${course.tpProgress.toStringAsFixed(1)}%',
              style: TextStyle(
                color: _getProgressColor(course.tpProgress),
                fontWeight: FontWeight.bold,
              ),
            )),
            DataCell(Text(
              '${course.totalCompletedHours.toStringAsFixed(1)}/${course.totalPlannedHours.toStringAsFixed(1)}\n${course.totalProgress.toStringAsFixed(1)}%',
              style: TextStyle(
                color: _getProgressColor(course.totalProgress),
                fontWeight: FontWeight.bold,
              ),
            )),
          ],
        );
      }).toList(),
    );
  }
}
