import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
            child: Column(
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Welcome to Bloom!!',
                  style: const TextStyle().copyWith(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
            )),
            Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        final user = await signInWithGoogle();

                        if (!context.mounted) return;

                        if (user.user != null) {
                          context.go('/');
                        } else {
                          const AlertDialog(
                            content: Text('Please Login!'),
                          );
                        }
                      },
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Get started with Google')),
            )
          ],
        )));
  }
}

class AuthNotifier extends ChangeNotifier {
  late final Stream<User?> _authStream;

  AuthNotifier() {
    _authStream = FirebaseAuth.instance.authStateChanges();
    _authStream.listen((_) => notifyListeners());
  }
}

Future<UserCredential> signInWithGoogle() async {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

  final GoogleSignInAuthentication googleAuth =
      await googleUser!.authentication;

  return await FirebaseAuth.instance.signInWithCredential(
    GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    ),
  );
}
