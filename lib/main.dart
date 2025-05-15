import 'dart:async';
import 'dart:ui';

import 'package:bloom/func/authnotifier.dart';
import 'package:bloom/provider/theme_provider.dart';
import 'package:bloom/screens/auth/auth.dart';
import 'package:bloom/screens/Home/editprofile.dart';
import 'package:bloom/screens/Home/home.dart';
import 'package:bloom/screens/Home/settings.dart';
import 'package:bloom/screens/auth/setup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runZonedGuarded(() {
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
  });
}

final _router = GoRouter(
  refreshListenable: ProviderContainer().read(authNotifierProvider.notifier),
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        redirect: (BuildContext context, GoRouterState state) {
          final user = FirebaseAuth.instance.currentUser;
          return user == null ? '/auth' : null;
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
            builder: (context, state) => const EditProfile(),
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
    return Consumer(
      builder: (context, ref, _) {
        final themeMode = ref.watch(themeNotifierProvider);

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
            themeMode: themeMode,
          );
        });
      },
    );
  }
}
