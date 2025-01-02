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
      final lastUpdate = await _storage.getLastUpdateTime();
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/updates'),
        headers: {
          'If-Modified-Since': lastUpdate?.toIso8601String() ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lastModified = DateTime.parse(data['last_modified']);
        return lastModified.isAfter(lastUpdate ?? DateTime(0));
      }
      return false;
    } catch (e) {
      print('Error checking for updates: $e');
      return false;
    }
  }

  // Get schedule metadata
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

  // Get schedule sessions
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

  // Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}