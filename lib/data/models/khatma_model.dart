class KhatmaModel {
  final int dailyPages;
  final int startPage;
  final int currentPage;
  final DateTime startDate;
  final bool completed;

  /// Optional user-chosen finish date.
  final DateTime? targetDate;

  /// Last time progress advanced (for streak / pace display).
  final DateTime? lastReadDate;

  KhatmaModel({
    required this.dailyPages,
    required this.startPage,
    required this.currentPage,
    required this.startDate,
    required this.completed,
    this.targetDate,
    this.lastReadDate,
  });

  KhatmaModel copyWith({
    int? dailyPages,
    int? startPage,
    int? currentPage,
    DateTime? startDate,
    bool? completed,
    DateTime? targetDate,
    DateTime? lastReadDate,
  }) {
    return KhatmaModel(
      dailyPages: dailyPages ?? this.dailyPages,
      startPage: startPage ?? this.startPage,
      currentPage: currentPage ?? this.currentPage,
      startDate: startDate ?? this.startDate,
      completed: completed ?? this.completed,
      targetDate: targetDate ?? this.targetDate,
      lastReadDate: lastReadDate ?? this.lastReadDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailyPages': dailyPages,
      'startPage': startPage,
      'currentPage': currentPage,
      'startDate': startDate.toIso8601String(),
      'completed': completed,
      'targetDate': targetDate?.toIso8601String(),
      'lastReadDate': lastReadDate?.toIso8601String(),
    };
  }

  factory KhatmaModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseOrNull(Object? v) =>
        v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

    return KhatmaModel(
      dailyPages: (map['dailyPages'] as num?)?.toInt() ?? 1,
      startPage: (map['startPage'] as num?)?.toInt() ?? 1,
      currentPage: (map['currentPage'] as num?)?.toInt() ?? 1,
      startDate: parseOrNull(map['startDate']) ?? DateTime.now(),
      completed: map['completed'] as bool? ?? false,
      targetDate: parseOrNull(map['targetDate']),
      lastReadDate: parseOrNull(map['lastReadDate']),
    );
  }
}
