import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late SearchController controller;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    controller = SearchController();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: TextField(
        autofocus: false,
        decoration: const InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(50))),
          hintText: 'Search',
          prefixIcon: Icon(Icons.search),
        ),
        controller: controller,
        onTapOutside: (event) => {
          setState(() {
            searchQuery = '';
            controller.clear();
          }),
          FocusScope.of(context).unfocus()
        },
        onChanged: (value) {
          setState(() {
            searchQuery = value.trim();
          });
        },
      )),
      body: Column(
        children: [
          if (searchQuery.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Theme.of(context).cardTheme.color ?? Colors.grey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 10),
                  Text("Searching for \"$searchQuery\""),
                ],
              ),
            )
          else
            const SizedBox.shrink(),

          // Your normal chat or friend content goes here
          const Expanded(child: Center(child: Text("Chat screen content"))),
        ],
      ),
    );
  }
}
