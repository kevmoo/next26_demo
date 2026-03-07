import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => SignInScreen(
    providers: [EmailAuthProvider()],
    subtitleBuilder: (context, action) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: action == AuthAction.signIn
          ? const Text('Welcome to Sell Stuff, please sign in!')
          : const Text('Welcome to Sell Stuff, please sign up!'),
    ),
  );
}
