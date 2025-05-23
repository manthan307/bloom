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
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final taskList = ref.watch(taskListsProvider.notifier);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 2));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Card(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: isDark ? 0.2 : 1),
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
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: const Text('Rename List'),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          String newName = '';
                                          return AlertDialog(
                                            title: const Text('Rename List'),
                                            content: TextField(
                                              onChanged: (value) {
                                                newName = value;
                                              },
                                              decoration: const InputDecoration(
                                                hintText: 'Enter new name',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  taskList.renameList(
                                                    widget.index,
                                                    newName,
                                                  );
                                                  Navigator.popUntil(
                                                    context,
                                                    (route) => route.isFirst,
                                                  );
                                                },
                                                child: const Text('Rename'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
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
                                              taskList.removeList(widget.index);
                                              Navigator.pop(context);
                                            },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Column(
                  children: List.generate(1, (index) {
                    return ListTile(
                      title: Text('Todo Item $index'),
                      leading: Checkbox(
                        value: false,
                        onChanged: (value) {},
                        shape: const CircleBorder(),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.star_border_outlined),
                        onPressed: () {},
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
