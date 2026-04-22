import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_counter_shared/multi_counter_shared.dart';

import '../../constants.dart';
import '../../widgets/app_scaffold.dart';
import 'state.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  final state = CounterState();
  late final StreamSubscription<IncrementResponse> _sub;
  late final Listenable _merger;

  @override
  void initState() {
    super.initState();

    _merger = Listenable.merge([
      state.userCounter,
      state.globalCounter,
      state.currentUser,
    ]);

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
  Widget build(BuildContext context) => AppScaffold(
    child: ListenableBuilder(
      listenable: _merger,
      builder: (context, child) {
        final globalCount = state.globalCounter.value;
        final user = state.currentUser.value;
        final isLoggedIn = user != null;

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                appTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              _spacer,
              if (isLoggedIn) ...[
                const Text('You have pushed the button this many times:'),
                Text(
                  '${state.userCounter.value}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                _spacer,
              ],
              if (globalCount == null) const Text('...'),
              if (globalCount != null) ...[
                const Text('Total button pushes:'),
                Text(
                  '${globalCount.totalClicks}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                _spacer,
                const Text('Total people who have pushed the button:'),
                Text(
                  '${globalCount.totalUsers}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
              _spacer,
              if (isLoggedIn)
                FloatingActionButton.extended(
                  onPressed: state.increment,
                  tooltip: 'Increment',
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                )
              else
                ElevatedButton.icon(
                  onPressed: state.signInWithGoogle,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: spaceSize,
                      horizontal: doubleSpaceSize,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}

const _spacer = SizedBox(height: doubleSpaceSize);
