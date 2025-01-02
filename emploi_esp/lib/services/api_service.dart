// lib/services/api_service.dart

import 'dart:convert';
import 'package:emploi_esp/services/storage_service.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/schedule_model.dart';
import '../models/course_model.dart';
import '../models/plan_model.dart';
import '../models/progress_model.dart';

class ApiService {
  final http.Client _client = http.Client();
  final StorageService _storage = StorageService();

  // Schedule APIs
  Future<ScheduleMetadata> getScheduleMetadata() async {
    try {
      // Try to get from cache first
      final cachedData = await _storage.getData(ApiConfig.scheduleKey);
      if (cachedData != null) {
        return ScheduleMetadata.fromJson(cachedData['metadata']);
      }

      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.scheduleEndpoint}/metadata'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.saveData(ApiConfig.scheduleKey, data);
        return ScheduleMetadata.fromJson(data['metadata']);
      } else {
        throw Exception('Failed to load schedule metadata');
      }
    } catch (e) {
      throw Exception('Error fetching schedule metadata: $e');
    }
  }

  Future<List<ScheduleSession>> getScheduleSessions() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.scheduleEndpoint}/sessions'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['sessions'] as List)
            .map((json) => ScheduleSession.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load schedule sessions');
      }
    } catch (e) {
      throw Exception('Error fetching schedule sessions: $e');
    }
  }

  // Courses APIs
  Future<List<Course>> getCourses() async {
    try {
      // Try to get from cache first
      final cachedData = await _storage.getData(ApiConfig.coursesKey);
      if (cachedData != null) {
        return (cachedData['courses'] as List)
            .map((json) => Course.fromJson(json))
            .toList();
      }

      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.coursesEndpoint}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.saveData(ApiConfig.coursesKey, data);
        return (data['courses'] as List)
            .map((json) => Course.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    }
  }

  // Plan APIs
  Future<Map<String, DaySchedule>> getPlanSchedule() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.planEndpoint}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Map<String, DaySchedule> schedule = {};

        (data['schedule'] as Map<String, dynamic>).forEach((key, value) {
          schedule[key] = DaySchedule.fromJson(value);
        });

        return schedule;
      } else {
        throw Exception('Failed to load plan schedule');
      }
    } catch (e) {
      throw Exception('Error fetching plan schedule: $e');
    }
  }

  // Progress APIs
  Future<GlobalProgress> getGlobalProgress() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.progressEndpoint}/global'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GlobalProgress.fromJson(data['global_stats']);
      } else {
        throw Exception('Failed to load global progress');
      }
    } catch (e) {
      throw Exception('Error fetching global progress: $e');
    }
  }

  Future<List<CourseProgress>> getCourseProgress() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.progressEndpoint}/courses'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['courses_progress'] as List)
            .map((json) => CourseProgress.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load course progress');
      }
    } catch (e) {
      throw Exception('Error fetching course progress: $e');
    }
  }

  // Check for updates
  Future<bool> checkForUpdates() async {
    try {
      final lastUpdate = await _storage.getLastUpdateTime();
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/updates'),
        headers: {'If-Modified-Since': lastUpdate?.toIso8601String() ?? ''},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
