import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'my_state.dart';

class CountView extends StatelessWidget {
  const CountView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final state = MyState.instance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: const [SignOutButton()],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            ValueListenableBuilder<int>(
              valueListenable: state.userCounter,
              builder: (context, count, child) {
                return Text(
                  '$count',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            const Text('Everyone has bush the button this many times:'),
            ValueListenableBuilder<int>(
              valueListenable: state.globalConuter,
              builder: (context, count, child) {
                return Text(
                  '$count',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: state.doIncrement,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
