// lib/config/api_config.dart

class ApiConfig {
  // API Base URL
  static const String baseUrl = 'http://10.0.2.2:5000';

  // Refresh Intervals
  static const Duration refreshInterval = Duration(minutes: 5);
  static const Duration notificationInterval = Duration(minutes: 15);

  // API Endpoints
  static const String scheduleEndpoint = '/api/schedule';
  static const String coursesEndpoint = '/api/courses';
  static const String planEndpoint = '/api/plan';
  static const String progressEndpoint = '/api/progress';
  
  // Cache Keys
  static const String scheduleKey = 'schedule_data';
  static const String coursesKey = 'courses_data';
  static const String planKey = 'plan_data';
  static const String progressKey = 'progress_data';
}