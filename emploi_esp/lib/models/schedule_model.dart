// lib/models/schedule_model.dart

class ScheduleMetadata {
  final String semester;
  final int week;
  final DateTime startDate;
  final DateTime endDate;

  ScheduleMetadata({
    required this.semester,
    required this.week,
    required this.startDate,
    required this.endDate,
  });

  factory ScheduleMetadata.fromJson(Map<String, dynamic> json) {
    return ScheduleMetadata(
      semester: json['semester'],
      week: json['week'],
      startDate: DateTime.parse(json['date_range']['start']),
      endDate: DateTime.parse(json['date_range']['end']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'semester': semester,
      'week': week,
      'date_range': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
    };
  }
}

class ScheduleSession {
  final String code;
  final String type;
  final String room;
  final String name;
  final String professor;
  final int timeSlot;
  final String day;

  ScheduleSession({
    required this.code,
    required this.type,
    required this.room,
    required this.name,
    required this.professor,
    required this.timeSlot,
    required this.day,
  });

  factory ScheduleSession.fromJson(Map<String, dynamic> json) {
    return ScheduleSession(
      code: json['code'],
      type: json['type'],
      room: json['room'],
      name: json['name'],
      professor: json['professor'],
      timeSlot: json['time_slot'],
      day: json['day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'type': type,
      'room': room,
      'name': name,
      'professor': professor,
      'time_slot': timeSlot,
      'day': day,
    };
  }
}