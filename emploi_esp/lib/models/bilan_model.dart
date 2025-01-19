class BilanData {
  final String code;
  final String title;
  final int credits;
  final double cmHours;
  final double tdHours;
  final double tpHours;
  final double cmCompleted;
  final double tdCompleted;
  final double tpCompleted;
  final double cmProgress;
  final double tdProgress;
  final double tpProgress;
  final double totalProgress;

  BilanData({
    required this.code,
    required this.title,
    required this.credits,
    required this.cmHours,
    required this.tdHours,
    required this.tpHours,
    required this.cmCompleted,
    required this.tdCompleted,
    required this.tpCompleted,
    required this.cmProgress,
    required this.tdProgress,
    required this.tpProgress,
    required this.totalProgress,
  });

  factory BilanData.fromJson(Map<String, dynamic> json) {
    if (json['code']?.toString().trim().isEmpty ?? true) {
      throw const FormatException('Course code cannot be empty');
    }

    final cmHours = (json['cm_hours'] ?? 0).toDouble();
    final tdHours = (json['td_hours'] ?? 0).toDouble();
    final tpHours = (json['tp_hours'] ?? 0).toDouble();
    
    final cmCompleted = (json['cm_completed'] ?? 0).toDouble();
    final tdCompleted = (json['td_completed'] ?? 0).toDouble();
    final tpCompleted = (json['tp_completed'] ?? 0).toDouble();

    // Calculate progress based on actual hours
    final cmProgress = cmHours > 0 
        ? (cmCompleted / cmHours * 100).clamp(0.0, 100.0) 
        : 0.0;
    final tdProgress = tdHours > 0 
        ? (tdCompleted / tdHours * 100).clamp(0.0, 100.0) 
        : 0.0;
    final tpProgress = tpHours > 0 
        ? (tpCompleted / tpHours * 100).clamp(0.0, 100.0) 
        : 0.0;

    // Calculate total progress based on total hours
    final totalHours = cmHours + tdHours + tpHours;
    final totalCompleted = cmCompleted + tdCompleted + tpCompleted;
    final totalProgress = totalHours > 0 
        ? ((totalCompleted / totalHours) * 100).clamp(0.0, 100.0)
        : 0.0;

    return BilanData(
      code: json['code'],
      title: json['title'] ?? '',
      credits: (json['credits'] ?? 0).toInt(),
      cmHours: cmHours,
      tdHours: tdHours,
      tpHours: tpHours,
      cmCompleted: cmCompleted,
      tdCompleted: tdCompleted,
      tpCompleted: tpCompleted,
      cmProgress: cmProgress,
      tdProgress: tdProgress,
      tpProgress: tpProgress,
      totalProgress: totalProgress,
    );
  }

  // Calculate total planned and completed hours
  double get totalPlannedHours => (cmHours + tdHours + tpHours);
  double get totalCompletedHours => cmCompleted + tdCompleted + tpCompleted;

  @override
  String toString() {
    return 'BilanData(code: $code, title: $title, credits: $credits\n'
           'CM: ${cmCompleted.toStringAsFixed(1)}/$cmHours hours (${cmProgress.toStringAsFixed(1)}%)\n'
           'TD: ${tdCompleted.toStringAsFixed(1)}/$tdHours hours (${tdProgress.toStringAsFixed(1)}%)\n'
           'TP: ${tpCompleted.toStringAsFixed(1)}/$tpHours hours (${tpProgress.toStringAsFixed(1)}%)\n'
           'Total Progress: ${totalProgress.toStringAsFixed(1)}%)';
  }
}

class BilanSemester {
  final List<BilanData> courses;
  final double averageProgress;

  BilanSemester({
    required this.courses,
    required this.averageProgress,
  });

  factory BilanSemester.fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic> coursesJson = json['courses'] ?? [];
      final courses = coursesJson
          .map((courseJson) => BilanData.fromJson(courseJson))
          .where((course) => course.code.isNotEmpty) // Filter out invalid courses
          .toList()
          ..sort((a, b) => a.code.compareTo(b.code)); // Sort by course code

      // Calculate average progress weighted by credits
      final totalCredits = courses.fold<int>(0, (sum, course) => sum + course.credits);
      final weightedProgress = courses.fold<double>(
          0,
          (sum, course) => sum + (course.totalProgress * course.credits));
      
      final averageProgress = totalCredits > 0 
          ? (weightedProgress / totalCredits).clamp(0.0, 100.0)
          : 0.0;

      print('Created BilanSemester with ${courses.length} valid courses');
      return BilanSemester(
        courses: courses,
        averageProgress: averageProgress,
      );
    } catch (e) {
      print('Error converting JSON to BilanSemester: $e');
      rethrow;
    }
  }
}
