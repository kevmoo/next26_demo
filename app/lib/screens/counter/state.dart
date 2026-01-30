import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
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
  }

  final ValueNotifier<int> userCounter = ValueNotifier(0);
  final ValueNotifier<int> globalCounter = ValueNotifier(0);

  final _incrementController = StreamController<void>.broadcast();

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
  }
}
