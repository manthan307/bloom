import 'package:bloom/provider/theme_provider.dart';
import 'package:bloom/provider/user_provider.dart';
import 'package:bloom/screens/auth/auth.dart';
import 'package:bloom/screens/auth/editprofile.dart';
import 'package:bloom/screens/home.dart';
import 'package:bloom/screens/auth/settings.dart';
import 'package:bloom/screens/auth/setup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final authNotifier = AuthNotifier();

final _router = GoRouter(
  refreshListenable: authNotifier,
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        redirect: (BuildContext context, GoRouterState state) {
          if (FirebaseAuth.instance.currentUser?.email == null) {
            // User is not logged in, redirect to auth page
            return '/auth';
          } else {
            // User is logged in, return null to stay on the current route
            return null;
          }
        },
        routes: [
          GoRoute(
              path: '/setup',
              builder: (context, state) => const ProfileSetup()),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const Settings(),
          ),
          GoRoute(
            path: '/edit',
            builder: (context, state) => const Editprofile(),
          )
        ]),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const Auth(),
    )
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _defaultLightColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light,
  );

  static final _defaultDarkColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightDynamic ?? _defaultLightColorScheme),
        darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkDynamic ?? _defaultDarkColorScheme),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        themeMode: themeProvider.themeMode,
      );
    });
  }
}
