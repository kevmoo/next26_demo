import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:next26_shared/next26_shared.dart';
import 'package:stream_transform/stream_transform.dart';

typedef GlobalData = ({int totalUsers, int totalClicks});

class CounterState {
  CounterState() {
    _incrementController.stream
        .switchMap(
          (_) => FirebaseFunctions.instance
              .httpsCallable(incrementCallable)
              .call<Object?>()
              .asStream(),
        )
        .listen(_handleIncrementResult);

    _initFirestore();
  }

  final ValueNotifier<int> userCounter = ValueNotifier(0);
  final ValueNotifier<GlobalData?> globalCounter = ValueNotifier(null);

  final _incrementController = StreamController<void>.broadcast();
  final _subscriptions = <StreamSubscription>[];
  final _responseController = StreamController<IncrementResponse>.broadcast();

  Stream<IncrementResponse> get incrementResponseStream =>
      _responseController.stream;

  // TODO: consider creating shared constants for collection and field names.
  // ...and putting them in the shared package.
  void _initFirestore() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _subscriptions.add(
        FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(uid)
            .snapshots()
            .listen((snapshot) {
              if (snapshot.exists) {
                final data = snapshot.data();
                if (data != null && data.containsKey(countField)) {
                  userCounter.value = data[countField] as int;
                }
              }
            }),
      );

      _subscriptions.add(
        FirebaseFirestore.instance
            .collection(globalCollection)
            .doc(varsDocument)
            .snapshots()
            .listen((snapshot) {
              if (snapshot.data() case {
                totalCountField: int totalClicks,
                totalUsersField: int totalUsers,
              }) {
                globalCounter.value = (
                  totalUsers: totalUsers,
                  totalClicks: totalClicks,
                );
              }
            }),
      );
    } else {
      print('no uid');
    }
  }

  // TODO: consider making this a nullable-property and disabling
  // the button when we're waiting for the function to complete.
  void increment() {
    _incrementController.add(null);
  }

  void _handleIncrementResult(HttpsCallableResult<Object?> result) {
    if (result.data case {'data': Map<String, Object?> data}) {
      final response = IncrementResponse.fromJson(data);
      _responseController.add(response);
    } else {
      print('Unexpected data format: ${result.data}');
    }
  }

  void dispose() {
    _responseController.close();
    _incrementController.close();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
  }
}
