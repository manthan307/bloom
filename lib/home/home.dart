import 'package:bloom/home/todo.dart';
import 'package:bloom/utils/provider/theme_provider.dart';
import 'package:bloom/utils/provider/todo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final PageController _pageController = PageController(initialPage: 1);
  int _selectedIndex = 1;

  void _onTabTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showNewListDialog() async {
    final controller = TextEditingController();

    final listName = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('New List'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'List name'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, controller.text); // Return name
                },
                child: Text('Create'),
              ),
            ],
          ),
    );

    if (listName != null && listName.trim().isNotEmpty) {
      final notifier = ref.read(taskListsProvider.notifier);
      notifier.addList(listName);

      // Wait for the UI to update (ensures list is added)
      await Future.delayed(Duration(milliseconds: 100));

      final newIndex =
          ref.read(taskListsProvider).length; // 1 for favourites + index

      setState(() {
        _selectedIndex = newIndex;
      });
      _pageController.animateToPage(
        newIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildTab(int index, {Icon? icon, String? title}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabTap(index),
      child: Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          border:
              isSelected
                  ? Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  )
                  : null,
        ),
        child:
            title != null
                ? Text(
                  title,
                  style: TextStyle(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
                : icon != null
                ? Icon(
                  icon.icon,
                  color:
                      isSelected ? Theme.of(context).colorScheme.primary : null,
                  size: 24,
                )
                : SizedBox.shrink(),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, {Icon? icon}) {
    return TextButton.icon(onPressed: onPressed, label: Text(text), icon: icon);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final taskLists = ref.watch(taskListsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bloom'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(!isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme(!isDark);
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTab(0, icon: Icon(Icons.star_border_outlined)),
                  for (int i = 0; i < taskLists.length; i++)
                    _buildTab(i + 1, title: taskLists[i].name),
                  _buildButton('New List', () {
                    _showNewListDialog();
                  }, icon: Icon(Icons.add)),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                Center(child: Text('Favourites')),
                for (int i = 0; i < taskLists.length; i++)
                  Todo(
                    tasks: taskLists[i].tasks,
                    title: taskLists[i].name,
                    index: i,
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            isScrollControlled: true,

            context: context,
            builder: (BuildContext context) {
              return BottomSheetWidget();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({super.key});

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  final TextEditingController titleEditingController = TextEditingController();
  final TextEditingController descriptionEditingController =
      TextEditingController();
  bool isButtonEnable = false;
  bool isDescriptionEnable = false;
  bool isFav = false;

  @override
  void initState() {
    super.initState();
    titleEditingController.addListener(() {
      setState(() {
        isButtonEnable = titleEditingController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    titleEditingController.dispose();
    descriptionEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'New Task',
              border: InputBorder.none,
              labelStyle: TextStyle(
                fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
              ),
            ),
            controller: titleEditingController,
          ),
          isDescriptionEnable
              ? TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: InputBorder.none,
                  labelStyle: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleSmall?.fontSize,
                  ),
                ),
                controller: descriptionEditingController,
              )
              : SizedBox.shrink(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    descriptionEditingController.clear();
                    isDescriptionEnable = !isDescriptionEnable;
                  });
                },
                icon: Icon(Icons.sort),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.alarm_outlined)),
              IconButton(
                onPressed: () {
                  setState(() {
                    isFav = !isFav;
                  });
                },
                icon:
                    isFav
                        ? Icon(
                          Icons.star,
                          color: Theme.of(context).colorScheme.primary,
                        )
                        : Icon(Icons.star_border),
              ),
              Spacer(),
              TextButton(
                onPressed:
                    isButtonEnable
                        ? () {
                          // Save the new task
                          titleEditingController.clear();
                          setState(() {
                            isButtonEnable = false;
                          });
                          Navigator.pop(context);
                        }
                        : null,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color:
                        !isButtonEnable
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
