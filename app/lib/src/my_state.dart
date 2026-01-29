import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class MyState {
  MyState._();
  final ValueNotifier<int> userCounter = ValueNotifier(0);
  final ValueNotifier<int> globalConuter = ValueNotifier(0);

  bool _inFlight = false;

  void Function()? get doIncrement {
    if (_inFlight) {
      return null;
    }
    return _doCall;
  }

  Future<void> _doCall() async {
    print('doIncrement');
    if (_inFlight) {
      print('in flight');
      return;
    }

    _inFlight = true;
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('increment')
          .call<Object?>();

      print(result.data);
    } finally {
      _inFlight = false;
    }
  }

  static final MyState instance = MyState._();
}
