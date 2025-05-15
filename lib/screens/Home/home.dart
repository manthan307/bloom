import 'package:bloom/screens/Home/profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: TabBarView(children: [
          Center(
              child: ElevatedButton(
                  onPressed: () {
                    context.go('/setup');
                  },
                  child: const Text('set up'))),
          const Text('About'),
          const Text('contact'),
          const Profile()
        ]),
        bottomNavigationBar: const TabBar(
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
