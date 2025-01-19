import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/schedule_model.dart';
import '../services/storage_service.dart';

class ApiService {
  final http.Client _client = http.Client();
  final StorageService _storage = StorageService();

  // Check for updates
  Future<bool> checkForUpdates() async {
    try {
      // Instead of checking a separate updates endpoint,
      // we'll compare the current data with new data
      final currentWeek = 1; // Start with week 1 by default
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.scheduleEndpoint}/$currentWeek/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> newData = json.decode(response.body);
        final cachedData = await _storage.getData(ApiConfig.scheduleKey);
        
        if (cachedData == null) {
          await _storage.saveData(ApiConfig.scheduleKey, {'data': newData});
          return true;
        }

        // Compare the new data with cached data
        final hasChanges = json.encode(newData) != json.encode(cachedData['data']);
        if (hasChanges) {
          await _storage.saveData(ApiConfig.scheduleKey, {'data': newData});
        }
        return hasChanges;
      }
      return false;
    } catch (e) {
      print('Error checking for updates: $e');
      return false;
    }
  }

  // Get schedule metadata
  Future<ScheduleMetadata> getScheduleMetadata(int week) async {
    try {
      // For metadata, we'll use the schedule data to construct metadata
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.scheduleEndpoint}/$week/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Create metadata from schedule data
        return ScheduleMetadata(
          semester: 'Current',  // This can be enhanced later
          week: week,
          startDate: DateTime.now(),  // These can be enhanced later
          endDate: DateTime.now().add(const Duration(days: 7)),
        );
      } else {
        throw Exception('Failed to load schedule metadata');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get schedule sessions
  Future<List<ScheduleSession>> getScheduleSessions(int week) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.scheduleEndpoint}/$week/');
      if (ApiConfig.debugMode) {
        print('Fetching schedule from: $url');
      }

      final response = await _client.get(url);

      if (ApiConfig.debugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (ApiConfig.debugMode) {
          print('Decoded ${data.length} sessions');
        }

        final sessions = data.map((json) {
          if (ApiConfig.debugMode) {
            print('Processing session: $json');
          }

          final session = ScheduleSession(
            code: json['course_code'] ?? '',
            type: json['type'] ?? '',
            room: json['room'] ?? '',
            name: json['course_code'] ?? '',
            professor: json['professor'] ?? '',
            timeSlot: _convertPeriodToTimeSlot(json['period'] ?? ''),
            day: json['day'] ?? '', 
          );

          if (ApiConfig.debugMode) {
            print('Created session: {code: ${session.code}, day: ${session.day}, timeSlot: ${session.timeSlot}}');
          }

          return session;
        }).toList();

        // Sort sessions by time slot
        sessions.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

        if (ApiConfig.debugMode) {
          print('Returning ${sessions.length} processed sessions');
          sessions.forEach((s) => print('Session: ${s.code} on ${s.day} at slot ${s.timeSlot}'));
        }

        return sessions;
      } else {
        throw Exception('Failed to load schedule sessions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading sessions: $e');
      rethrow;
    }
  }

  String _convertDay(String day) {
    return day;
  }

  int _convertPeriodToTimeSlot(String period) {
    if (ApiConfig.debugMode) {
      print('Converting period: $period');
    }
    final periodMap = {
      'P1': 1,
      'P2': 2,
      'P3': 3,
      'P4': 4,
      'P5': 5,
      'P6': 6,
    };
    return periodMap[period] ?? 1;
  }

  // Dispose the HTTP client
  void dispose() {
    _client.close();
  }
  
  String _handleError(Object e) {
    print('API Error: $e');
    if (e is Exception) {
      return e.toString();
    }
    return 'An unexpected error occurred';
  }
}