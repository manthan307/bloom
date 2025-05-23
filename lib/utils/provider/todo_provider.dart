import 'package:bloom/utils/models/task_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskListsProvider =
    StateNotifierProvider<TaskListsNotifier, List<TaskList>>((ref) {
      return TaskListsNotifier([
        TaskList(name: 'My Tasks', tasks: []), // Default list
      ]);
    });

class TaskListsNotifier extends StateNotifier<List<TaskList>> {
  TaskListsNotifier(super.initialLists);

  void addList(String name) {
    state = [...state, TaskList(name: name)];
  }

  void addTask(int listIndex, TaskModel task) {
    final updatedLists = [...state];
    updatedLists[listIndex].tasks.add(task);
    state = updatedLists;
  }

  void removeList(int index) {
    // If trying to remove "My Tasks", ignore
    if (index == 0) return;

    final updatedLists = [...state];
    updatedLists.removeAt(index);
    state = updatedLists;
  }

  void renameList(int index, String newName) {
    final updatedLists = [...state];
    updatedLists[index].name = newName;
    state = updatedLists;
  }
}
