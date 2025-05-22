import 'package:bloom/home/todo.dart';
import 'package:bloom/utils/provider/theme_provider.dart';
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

  Widget _buildTab(int index, {Icon? icon, String? title}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabTap(index),
      child: Container(
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
    return ElevatedButton.icon(
      onPressed: onPressed,
      label: Text(text),
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildTab(0, icon: Icon(Icons.star_border_outlined)),
              _buildTab(1, title: 'My Tasks'),
              _buildButton('New List', () {}, icon: Icon(Icons.add)),
            ],
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                Center(child: Text('Favourites')),
                Todo(),
                SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your action here
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
