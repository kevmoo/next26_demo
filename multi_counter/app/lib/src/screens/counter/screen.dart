import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_counter_shared/multi_counter_shared.dart';

import 'state.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key, required this.title});

  final String title;

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  final state = CounterState();
  late final StreamSubscription<IncrementResponse> _sub;

  @override
  void initState() {
    super.initState();

    ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
    snackBarController;

    _sub = state.incrementResponseStream.listen((response) {
      if (!mounted) return;

      final message = response.message;
      if (message != null && snackBarController == null) {
        snackBarController = ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: response.success ? null : Colors.red,
          ),
        );

        snackBarController?.closed.then((reason) {
          snackBarController = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
      actions: const [SignOutButton()],
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('You have pushed the button this many times:'),
          ValueListenableBuilder<int>(
            valueListenable: state.userCounter,
            builder: (context, count, child) => Text(
              '$count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 32),
          ValueListenableBuilder<GlobalData?>(
            valueListenable: state.globalCounter,
            builder: (context, count, child) => Text(
              count == null
                  ? '...'
                  : [
                      _Plurals.people.getFor(count.totalUsers),
                      _Plurals.has.getFor(count.totalUsers, noCount: true),
                      'pushed the button ',
                      _Plurals.time.getFor(count.totalClicks),
                    ].join(' '),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 32),
          FloatingActionButton.extended(
            onPressed: state.increment,
            tooltip: 'Increment',
            icon: const Icon(Icons.add),
            label: const Text('Increment'),
          ),
        ],
      ),
    ),
  );
}

enum _Plurals {
  people(singular: 'person', plural: 'people'),
  time(singular: 'time', plural: 'times'),
  has(singular: 'has', plural: 'have');

  final String singular;
  final String plural;

  const _Plurals({required this.singular, required this.plural});

  String getFor(int count, {bool noCount = false}) {
    if (noCount) {
      return count == 1 ? singular : plural;
    }
    return '$count ${count == 1 ? singular : plural}';
  }
}
