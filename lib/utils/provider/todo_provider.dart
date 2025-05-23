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

  void removeTask(int listIndex, TaskModel task) {
    final updatedLists = [...state];
    updatedLists[listIndex].tasks.remove(task);
    state = updatedLists;
  }

  void updateTask(int listIndex, TaskModel oldTask, TaskModel newTask) {
    final updatedLists = [...state];
    final taskIndex = updatedLists[listIndex].tasks.indexOf(oldTask);
    if (taskIndex != -1) {
      updatedLists[listIndex].tasks[taskIndex] = newTask;
    }
    state = updatedLists;
  }

  void toggleTaskCompletion(int listIndex, TaskModel task) {
    final updatedLists = [...state];
    final taskIndex = updatedLists[listIndex].tasks.indexOf(task);
    if (taskIndex != -1) {
      updatedLists[listIndex].tasks[taskIndex].isDone =
          !updatedLists[listIndex].tasks[taskIndex].isDone;

      if (updatedLists[listIndex].tasks[taskIndex].isDone) {
        updatedLists[listIndex].tasks[taskIndex].completedAt = DateTime.now();
      } else {
        updatedLists[listIndex].tasks[taskIndex].completedAt = null;
      }
    }
    state = updatedLists;
  }

  void toggleTaskFav(int listIndex, TaskModel task) {
    final updatedLists = [...state];
    final taskIndex = updatedLists[listIndex].tasks.indexOf(task);
    if (taskIndex != -1) {
      updatedLists[listIndex].tasks[taskIndex].fav =
          !updatedLists[listIndex].tasks[taskIndex].fav;
    }
    state = updatedLists;
  }

  void clearCompletedTasks(int listIndex) {
    final updatedLists = [...state];
    updatedLists[listIndex].tasks.removeWhere((task) => task.isDone);
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
