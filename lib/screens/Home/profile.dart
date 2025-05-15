import 'package:bloom/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<StatefulWidget> createState() => _Profile();
}

class _Profile extends State<Profile> {
  Future<void> _refreshUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider
        .refreshUser(); // Make sure this method exists in your provider
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final displayName = user?.name ?? "Anonymous";
    final photoURL = user?.photoURL ?? 'https://i.imgur.com/QCNbOAo.png';
    final bio = user?.bio;
    final username = user?.username ?? 'Anonymous';

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  context.go('/settings');
                },
                icon: const Icon(Icons.settings_outlined),
              )
            ],
          ),
          body: RefreshIndicator(
              onRefresh: _refreshUser,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Important
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // Card Container
                          Container(
                            margin: const EdgeInsets.only(top: 60),
                            padding: const EdgeInsets.only(top: 70, bottom: 20),
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '@$username',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                                const SizedBox(height: 8),

                                // Bio Section
                                if (bio != null)
                                  Text(
                                    bio,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontSize: 13,
                                        height: 1.4),
                                  ),
                                const SizedBox(height: 16),

                                // Stats
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        const Text("0",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        Text('Friends',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Edit Profile Button
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                      onPressed: () {
                                        context.go('/edit');
                                      },
                                      icon: const Icon(Icons.edit_outlined,
                                          size: 18),
                                      label: const Text("Edit Profile"),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share_outlined),
                                      onPressed: () async {
                                        final profileLink =
                                            "https://bloomapp.com/u/$username"; // Replace with your actual URL format
                                        final message =
                                            "Check out my profile on Bloom 🌱\n\nMy username: @$username\n$profileLink";
                                        SharePlus.instance
                                            .share(ShareParams(text: message));
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),

                          // Profile Image (floating)
                          Positioned(
                            top: 0,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(photoURL),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const StatCard(
                      icon: Icons.timer_outlined,
                      title: 'Focus Hours',
                      value: '18.5 hrs',
                      color: Colors.deepPurple,
                    ),
                    const StatCard(
                      icon: Icons.check_circle_outline,
                      title: 'Tasks Completed',
                      value: '32',
                      color: Colors.green,
                    ),
                    const StatCard(
                      icon: Icons.local_fire_department_outlined,
                      title: 'Streak',
                      value: '7 Days 🔥',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ))),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(
                    Theme.of(context).brightness == Brightness.dark
                        ? 0.2
                        : 0.1),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 4),
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
