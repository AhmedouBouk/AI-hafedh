// lib/config/api_config.dart

class ApiConfig {
  // API Base URL
  static const String baseUrl = 'http://192.168.101.13:8000';

  // API Endpoints
  static const String scheduleEndpoint = '/api/schedule';
  
  // Debug mode
  static const bool debugMode = true;

  // Refresh Intervals
  static const Duration refreshInterval = Duration(minutes: 5);
  static const Duration notificationInterval = Duration(minutes: 15);

  static const String coursesEndpoint = '/api/courses';

  static const String progressEndpoint = '/api/progress';

  // Cache Keys
  static const String scheduleKey = 'schedule_data';
  static const String coursesKey = 'courses_data';

  static const String progressKey = 'progress_data';
}
