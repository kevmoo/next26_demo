import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => SignInScreen(
    providers: [GoogleProvider(clientId: webClientId)],
    subtitleBuilder: (context, action) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: action == AuthAction.signIn
          ? const Text('Welcome to FlutterFire, please sign in!')
          : const Text('Welcome to FlutterFire, please sign up!'),
    ),
    footerBuilder: (context, action) => const Padding(
      padding: EdgeInsets.only(top: 16),
      child: Text(
        'By signing in, you agree to our terms and conditions.',
        style: TextStyle(color: Colors.grey),
      ),
    ),
  );
}
