import 'package:bloom/utils/models/task_model.dart';
import 'package:bloom/utils/provider/theme_provider.dart';
import 'package:bloom/utils/provider/todo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo extends ConsumerStatefulWidget {
  const Todo({
    super.key,
    required this.tasks,
    required this.title,
    required this.index,
  });

  final List<TaskModel> tasks;
  final String title;
  final int index;

  @override
  ConsumerState<Todo> createState() => _TodoState();
}

class _TodoState extends ConsumerState<Todo> {
  late TextEditingController renameController;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    isExpanded = false;
    renameController = TextEditingController(text: widget.title);
  }

  @override
  void dispose() {
    renameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final taskList = ref.watch(taskListsProvider.notifier);
    final completedTasks = widget.tasks.where((task) => task.isDone).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 2));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(
                alpha: isDark ? 0.2 : 1,
              ),
              elevation: 0,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.swap_vert),

                          onPressed: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return AnimatedPadding(
                                  duration: const Duration(milliseconds: 300),
                                  padding: MediaQuery.of(context).viewInsets,
                                  curve: Curves.easeOut,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: const Text('Rename List'),
                                          onTap: () {
                                            showGeneralDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              barrierLabel: "Rename Dialog",
                                              transitionDuration:
                                                  const Duration(
                                                    milliseconds: 300,
                                                  ),
                                              pageBuilder:
                                                  (
                                                    context,
                                                    animation1,
                                                    animation2,
                                                  ) => AlertDialog(
                                                    title: const Text(
                                                      "Rename List",
                                                    ),
                                                    content: TextField(
                                                      controller:
                                                          renameController,
                                                      decoration: const InputDecoration(
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  10,
                                                                ),
                                                              ),
                                                        ),
                                                        hintText:
                                                            'Enter new name',
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          taskList.renameList(
                                                            widget.index,
                                                            renameController
                                                                .text,
                                                          );
                                                          Navigator.popUntil(
                                                            context,
                                                            (route) =>
                                                                route.isFirst,
                                                          );
                                                        },
                                                        child: const Text(
                                                          "Rename",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              transitionBuilder: (
                                                context,
                                                anim1,
                                                anim2,
                                                child,
                                              ) {
                                                return ScaleTransition(
                                                  scale: CurvedAnimation(
                                                    parent: anim1,
                                                    curve: Curves.easeOutBack,
                                                  ),
                                                  child: child,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        ListTile(
                                          title: Text(
                                            'Delete All Completed Tasks',
                                            style: TextStyle(
                                              color:
                                                  completedTasks.isEmpty
                                                      ? Colors.grey
                                                      : null,
                                            ),
                                          ),
                                          onTap:
                                              completedTasks.isEmpty
                                                  ? null
                                                  : () {
                                                    ref
                                                        .watch(
                                                          taskListsProvider
                                                              .notifier,
                                                        )
                                                        .clearCompletedTasks(
                                                          widget.index,
                                                        );
                                                    Navigator.pop(context);
                                                  },
                                        ),
                                        ListTile(
                                          title: Text(
                                            'Delete',
                                            style: TextStyle(
                                              color:
                                                  widget.index == 0
                                                      ? Colors.grey
                                                      : null,
                                            ),
                                          ),
                                          onTap:
                                              widget.index == 0
                                                  ? null
                                                  : () {
                                                    taskList.removeList(
                                                      widget.index,
                                                    );
                                                    Navigator.pop(context);
                                                  },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    widget.tasks.isEmpty
                        ? const SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(
                              'Try adding a task by clicking the + button',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.tasks.length,
                          itemBuilder: (context, index) {
                            final incompleteTasks =
                                widget.tasks
                                    .where((task) => !task.isDone)
                                    .toList();

                            if (incompleteTasks.isEmpty) {
                              return SizedBox(
                                height: 200,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'All tasks completed',
                                        style: TextStyle(
                                          fontSize:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleLarge?.fontSize,
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleLarge?.color,
                                        ),
                                      ),
                                      Text(
                                        'Nice Work!',
                                        style: TextStyle(
                                          fontSize:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleSmall?.fontSize,
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleSmall?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return !widget.tasks[index].isDone
                                ? ListTile(
                                  title: Text(
                                    widget.tasks[index].title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          widget.tasks[index].isDone
                                              ? Colors.grey
                                              : null,
                                      decoration:
                                          widget.tasks[index].isDone
                                              ? TextDecoration.lineThrough
                                              : null,
                                    ),
                                  ),
                                  subtitle:
                                      widget.tasks[index].completedAt != null
                                          ? Text(
                                            'Completed at: ${widget.tasks[index].completedAt!.hour}:${widget.tasks[index].completedAt!.minute}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          )
                                          : null,
                                  leading: Checkbox(
                                    value: widget.tasks[index].isDone,
                                    onChanged: (value) {
                                      taskList.toggleTaskCompletion(
                                        index,
                                        widget.tasks[index],
                                      );
                                    },
                                    shape: const CircleBorder(),
                                  ),
                                  trailing: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder:
                                        (child, animation) => ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                    child: IconButton(
                                      key: ValueKey(widget.tasks[index].fav),
                                      icon: Icon(
                                        widget.tasks[index].fav
                                            ? Icons.star
                                            : Icons.star_border_outlined,
                                        color:
                                            widget.tasks[index].fav
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                                : null,
                                      ),
                                      onPressed: () {
                                        taskList.toggleTaskFav(
                                          index,
                                          widget.tasks[index],
                                        );
                                      },
                                    ),
                                  ),
                                )
                                : null;
                          },
                        ),
                  ],
                ),
              ),
            ),
            if (completedTasks.isNotEmpty)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer
                    .withValues(alpha: isDark ? 0.2 : 1),
                elevation: 0,
                margin: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: SizedBox(
                          child: Row(
                            children: [
                              Text(
                                'Completed Tasks',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Spacer(),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Column(
                          children: [
                            if (isExpanded) const SizedBox(height: 10),
                            if (isExpanded)
                              ListView.builder(
                                itemCount: completedTasks.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      completedTasks[index].title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            completedTasks[index].isDone
                                                ? Colors.grey
                                                : null,
                                        decoration:
                                            completedTasks[index].isDone
                                                ? TextDecoration.lineThrough
                                                : null,
                                      ),
                                    ),
                                    subtitle:
                                        completedTasks[index].completedAt !=
                                                null
                                            ? Text(
                                              'Completed at: ${completedTasks[index].completedAt!.hour}:${completedTasks[index].completedAt!.minute}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            )
                                            : null,
                                    leading: Checkbox(
                                      value: completedTasks[index].isDone,
                                      onChanged: (value) {
                                        taskList.toggleTaskCompletion(
                                          index,
                                          completedTasks[index],
                                        );
                                      },
                                      shape: const CircleBorder(),
                                    ),
                                    trailing: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      transitionBuilder:
                                          (child, animation) => ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          ),
                                      child: IconButton(
                                        key: ValueKey(widget.tasks[index].fav),
                                        icon: Icon(
                                          widget.tasks[index].fav
                                              ? Icons.star
                                              : Icons.star_border_outlined,
                                          color:
                                              widget.tasks[index].fav
                                                  ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                  : null,
                                        ),
                                        onPressed: () {
                                          taskList.toggleTaskFav(
                                            index,
                                            widget.tasks[index],
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
