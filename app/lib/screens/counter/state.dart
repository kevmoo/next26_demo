import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:stream_transform/stream_transform.dart';

class CounterState {
  CounterState() {
    _incrementController.stream
        .switchMap(
          (_) => FirebaseFunctions.instance
              .httpsCallable('increment')
              .call<Object?>()
              .asStream(),
        )
        .listen(_handleIncrementResult);

    _initFirestore();
  }

  final ValueNotifier<int> userCounter = ValueNotifier(0);
  final ValueNotifier<int?> globalCounter = ValueNotifier(null);

  final _incrementController = StreamController<void>.broadcast();
  final _subscriptions = <StreamSubscription>[];

  void _initFirestore() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _subscriptions.add(
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots()
            .listen((snapshot) {
              if (snapshot.exists) {
                final data = snapshot.data();
                if (data != null && data.containsKey('count')) {
                  userCounter.value = data['count'] as int;
                }
              }
            }),
      );

      _subscriptions.add(
        FirebaseFirestore.instance
            .collection('global')
            .doc('vars')
            .snapshots()
            .listen((snapshot) {
              if (snapshot.exists) {
                final data = snapshot.data();
                if (data != null && data.containsKey('totalCount')) {
                  globalCounter.value = data['totalCount'] as int;
                }
              }
            }),
      );
    } else {
      print('no uid');
    }
  }

  void increment() {
    _incrementController.add(null);
  }

  void _handleIncrementResult(HttpsCallableResult<Object?> result) {
    if (result.data case {
      'data': {
        'userCount': final int userCount,
        'totalCount': final int totalCount,
      },
    }) {
      userCounter.value = userCount;
      globalCounter.value = totalCount;
    } else {
      print('Unexpected data format: ${result.data}');
    }
  }

  void dispose() {
    _incrementController.close();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
  }
}
