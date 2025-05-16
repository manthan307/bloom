import 'package:bloom/screens/Home/chats.dart';
import 'package:bloom/screens/Home/profile.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 4,
      child: Scaffold(
        body: TabBarView(children: [
          ChatScreen(),
          Text('About'),
          Text('Contact'),
          Profile()
        ]),
        bottomNavigationBar: TabBar(
            dividerHeight: 0,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            splashBorderRadius: BorderRadius.all(Radius.circular(40)),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                icon: Icon(Icons.messenger_outline_rounded),
              ),
              Tab(
                icon: Icon(Icons.task_alt_outlined),
              ),
              Tab(
                icon: Icon(Icons.timer_outlined),
              ),
              Tab(
                icon: Icon(Icons.person_outlined),
              )
            ]),
      ),
    );
  }
}
