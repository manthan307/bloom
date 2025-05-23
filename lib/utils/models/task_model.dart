import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final bool isDone;
  final DateTime createdAt;
  final bool fav;
  final bool isAlarmSet;
  final DateTime? alarmDateTime;
  final String? alarmId;

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
      isAlarmSet: json['isAlarmSet'],
      alarmId: json['alarmId'],
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, description: $description, isDone: $isDone, createdAt: $createdAt,fav:$fav,isAlarmSet:$isAlarmSet, alarmDateTime:$alarmDateTime,alarmId:$alarmId)';
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
  );
}

class TaskList {
  String name;
  final List<TaskModel> tasks;

  TaskList({required this.name, this.tasks = const []});
}
