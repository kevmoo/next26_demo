import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_counter_shared/multi_counter_shared.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config_state.dart';
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
      state.qrScansCounter,
      ...state.emojiCounters.values,
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
    onSignInWithGoogle: state.signInWithGoogle,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FlutterLogo(size: 32),
                  const SizedBox(width: 12),
                  Text(
                    appTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(width: 12),
                  Image.asset(
                    'assets/firebase_logo.png',
                    width: 32,
                    height: 32,
                  ),
                ],
              ),

              _spacer,
              InkWell(
                onTap: () => launchUrl(Uri.parse(qrCodeUrl)),
                child: Column(
                  children: [
                    QrImageView(
                      data: qrCodeUrl,
                      size: 240.0,
                      eyeStyle: QrEyeStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Text('(Scan or click)'),
                  ],
                ),
              ),
              const SizedBox(height: doubleSpaceSize / 2),
              Text(
                'Total QR Scans: ${state.qrScansCounter.value}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              _spacer,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: emojiFields.entries.map((e) {
                  final count = state.emojiCounters[e.key]?.value ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AnimatedEmoji(emoji: e.value, count: count),
                  );
                }).toList(),
              ),
              if (isLoggedIn) ...[
                _spacer,
                const Text('You have pushed the button this many times:'),
                Text(
                  '${state.userCounter.value}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                _spacer,
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
                FloatingActionButton.extended(
                  onPressed: state.increment,
                  tooltip: 'Increment',
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                ),
              ],
            ],
          ),
        );
      },
    ),
  );
}

class AnimatedEmoji extends StatefulWidget {
  final String emoji;
  final int count;

  const AnimatedEmoji({required this.emoji, required this.count, super.key});

  @override
  State<AnimatedEmoji> createState() => _AnimatedEmojiState();
}

class _AnimatedEmojiState extends State<AnimatedEmoji>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _dy;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _dy = Tween<double>(
      begin: 0,
      end: -60,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant AnimatedEmoji oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count > oldWidget.count) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    clipBehavior: Clip.none,
    children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.emoji, style: const TextStyle(fontSize: 28)),
          Text('${widget.count}'),
        ],
      ),
      AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Positioned(
          top: _dy.value,
          child: Opacity(
            opacity: _opacity.value,
            child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
      ),
    ],
  );
}

const _spacer = SizedBox(height: doubleSpaceSize);
