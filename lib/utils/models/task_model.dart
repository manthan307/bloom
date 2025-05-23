import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class TaskModel {
  final String id;
  String title;
  String? description;
  bool isDone;
  final DateTime createdAt;
  bool fav;
  bool isAlarmSet;
  DateTime? alarmDateTime;
  String? alarmId;
  DateTime? completedAt;

  TaskModel({
    required this.title,
    this.description,
    this.fav = false,
    this.isDone = false,
    this.isAlarmSet = false,
    DateTime? createdAt,
    String? id,
    this.alarmDateTime,
    this.alarmId,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       id = id ?? _uuid.v4();

  TaskModel copyWith({
    String? title,
    String? description,
    bool? isDone,
    DateTime? createdAt,
    String? id,
    bool? fav,
    bool? isAlarmSet,
    DateTime? alarmDateTime,
    String? alarmId,
    DateTime? completedAt,
  }) {
    return TaskModel(
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      fav: fav ?? this.fav,
      isAlarmSet: isAlarmSet ?? this.isAlarmSet,
      alarmDateTime: alarmDateTime ?? this.alarmDateTime,
      alarmId: alarmId ?? this.alarmId,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isDone': isDone,
    'createdAt': createdAt.toIso8601String(),
    'fav': fav,
    'isAlarmSet': isAlarmSet,
    'alarmDateTime': alarmDateTime?.toIso8601String(),
    'alarmId': alarmId,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isDone: json['isDone'],
      createdAt: DateTime.parse(json['createdAt']),
      fav: json['fav'],
      alarmDateTime:
          json['alarmDateTime'] != null
              ? DateTime.parse(json['alarmDateTime'])
              : null,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
      isAlarmSet: json['isAlarmSet'],
      alarmId: json['alarmId'],
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, description: $description, isDone: $isDone, createdAt: $createdAt,fav:$fav,isAlarmSet:$isAlarmSet, alarmDateTime:$alarmDateTime,alarmId:$alarmId,completedAt:$completedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isDone == isDone &&
        other.fav == fav &&
        other.alarmDateTime == alarmDateTime &&
        other.alarmId == alarmId &&
        other.isAlarmSet == isAlarmSet &&
        other.completedAt == completedAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    isDone,
    createdAt,
    fav,
    isAlarmSet,
    alarmDateTime,
    alarmId,
    completedAt,
  );
}

class TaskList {
  String name;
  final List<TaskModel> tasks;

  TaskList({required this.name, this.tasks = const []});
}
