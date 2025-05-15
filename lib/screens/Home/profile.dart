import 'package:bloom/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class Profile extends ConsumerWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProfileProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => context.go('/settings'),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.read(userProfileProvider.notifier).fetchUser(),
          child: userAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Failed to load user.\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            data: (user) {
              if (user == null) {
                return const Center(child: Text('No user data available.'));
              }
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    UserInfoCard(
                      name: user.name,
                      username: user.username ?? 'Anonymous',
                      bio: user.bio,
                      photoURL:
                          user.photoURL ?? 'https://i.imgur.com/QCNbOAo.png',
                    ),
                    const SizedBox(height: 20),
                    const StatSection(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class UserInfoCard extends StatelessWidget {
  final String name;
  final String username;
  final String? bio;
  final String photoURL;

  const UserInfoCard({
    super.key,
    required this.name,
    required this.username,
    required this.bio,
    required this.photoURL,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.only(top: 70, bottom: 20),
            width: width * 0.9,
            decoration: BoxDecoration(
              color: theme.colorScheme.onInverseSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "@$username",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                if (bio != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      bio!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text(
                          '0',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Friends',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.go('/edit'),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ShareButton(username: username),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/avatar.png',
                  image: photoURL,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShareButton extends StatelessWidget {
  final String username;
  const ShareButton({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share_outlined),
      onPressed: () {
        final profileLink = 'https://bloomapp.com/u/$username';
        final message =
            'Check out my profile on Bloom 🌱\n\nMy username: @$username\n$profileLink';
        SharePlus.instance.share(ShareParams(text: message));
      },
    );
  }
}

class StatSection extends StatelessWidget {
  const StatSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        StatCard(
          icon: Icons.timer_outlined,
          title: 'Focus Hours',
          value: '18.5 hrs',
          color: Colors.deepPurple,
        ),
        StatCard(
          icon: Icons.check_circle_outline,
          title: 'Tasks Completed',
          value: '32',
          color: Colors.green,
        ),
        StatCard(
          icon: Icons.local_fire_department_outlined,
          title: 'Streak',
          value: '7 Days 🔥',
          color: Colors.orange,
        ),
      ],
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(isDark ? 0.2 : 0.1),
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
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
