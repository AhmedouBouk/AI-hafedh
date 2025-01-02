// lib/models/plan_model.dart

class PlanSession {
  final String code;
  final String type;
  final bool isEmpty;
  final bool isSpecial;
  final String specialText;

  PlanSession({
    this.code = '',
    this.type = '',
    this.isEmpty = true,
    this.isSpecial = false,
    this.specialText = '',
  });

  factory PlanSession.fromJson(Map<String, dynamic> json) {
    return PlanSession(
      code: json['code'] ?? '',
      type: json['type'] ?? '',
      isEmpty: json['is_empty'] ?? true,
      isSpecial: json['is_special'] ?? false,
      specialText: json['special_text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'type': type,
      'is_empty': isEmpty,
      'is_special': isSpecial,
      'special_text': specialText,
    };
  }
}

class DaySchedule {
  final List<PlanSession> p1;
  final List<PlanSession> p2;
  final List<PlanSession> p3;
  final List<PlanSession> p4;
  final List<PlanSession> p5;

  DaySchedule({
    required this.p1,
    required this.p2,
    required this.p3,
    required this.p4,
    required this.p5,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      p1: (json['p1'] as List).map((e) => PlanSession.fromJson(e)).toList(),
      p2: (json['p2'] as List).map((e) => PlanSession.fromJson(e)).toList(),
      p3: (json['p3'] as List).map((e) => PlanSession.fromJson(e)).toList(),
      p4: (json['p4'] as List).map((e) => PlanSession.fromJson(e)).toList(),
      p5: (json['p5'] as List).map((e) => PlanSession.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'p1': p1.map((e) => e.toJson()).toList(),
      'p2': p2.map((e) => e.toJson()).toList(),
      'p3': p3.map((e) => e.toJson()).toList(),
      'p4': p4.map((e) => e.toJson()).toList(),
      'p5': p5.map((e) => e.toJson()).toList(),
    };
  }
}