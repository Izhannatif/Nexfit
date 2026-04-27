// models/personal_goal.dart
class PersonalGoal {
  int? id;
  String goalType;
  double targetValue;
  String startDate;
  String endDate;

  PersonalGoal({
    this.id,
    required this.goalType,
    required this.targetValue,
    required this.startDate,
    required this.endDate,
  });

  factory PersonalGoal.fromJson(Map<String, dynamic> json) {
    return PersonalGoal(
      id: json['id'],
      goalType: json['goal_type'],
      targetValue: json['target_value'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_type': goalType,
      'target_value': targetValue,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}

// models/weekly_progress.dart
class WeeklyProgress {
  int? id;
  int personalGoalId;
  String date;
  double currentValue;

  WeeklyProgress({
    this.id,
    required this.personalGoalId,
    required this.date,
    required this.currentValue,
  });

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyProgress(
      id: json['id'],
      personalGoalId: json['personal_goal'],
      date: json['date'],
      currentValue: json['current_value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personal_goal': personalGoalId,
      'date': date,
      'current_value': currentValue,
    };
  }
}
