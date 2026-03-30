import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'about_popup.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;

  const AppScaffold({super.key, required this.child, this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? appTitle),
        actions: actions,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: child,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: spaceSize,
            vertical: spaceSize / 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => const AboutPopup(),
                    ),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('About'),
                  ),
                  if (user != null) ...[
                    const SizedBox(width: spaceSize),
                    Expanded(
                      child: Text(
                        user.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const SizedBox(width: spaceSize / 2),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => FirebaseAuth.instance.signOut(),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
