import 'package:bloom/utils/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditScreen extends ConsumerStatefulWidget {
  const EditScreen({super.key, required this.task, required this.listIndex});

  final TaskModel task;
  final int listIndex;
  @override
  ConsumerState<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit')),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter title',
              ),
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
              ),
            ),
            Row(
              children: [
                Icon(Icons.sort),
                SizedBox(width: 10),
                // TextField(
                //   // controller: _descriptionController,
                //   decoration: InputDecoration(
                //     border: InputBorder.none,
                //     hintText: 'Enter description',
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
