class KhatmaModel {

  final int dailyPages;

  final int startPage;

  final int currentPage;

  final DateTime startDate;

  final bool completed;

  KhatmaModel({

    required this.dailyPages,

    required this.startPage,

    required this.currentPage,

    required this.startDate,

    required this.completed,
  });

  Map<String, dynamic> toMap() {

    return {

      "dailyPages": dailyPages,

      "startPage": startPage,

      "currentPage": currentPage,

      "startDate":
      startDate.toIso8601String(),

      "completed": completed,
    };
  }

  factory KhatmaModel.fromMap(
      Map<String, dynamic> map) {

    return KhatmaModel(

      dailyPages: map['dailyPages'],

      startPage: map['startPage'],

      currentPage: map['currentPage'],

      startDate:
      DateTime.parse(map['startDate']),

      completed: map['completed'],
    );
  }
}