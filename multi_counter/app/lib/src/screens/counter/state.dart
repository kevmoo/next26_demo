import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_counter_shared/multi_counter_shared.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../config_state.dart';

typedef GlobalData = ({int totalUsers, int totalClicks});

class CounterState {
  CounterState() {
    _incrementController.stream
        .switchMap((_) => _callIncrement().asStream())
        .listen(_handleIncrementResult);

    _initFirestore();
    _listenToAuth();
  }

  final ValueNotifier<int> userCounter = ValueNotifier(0);
  final ValueNotifier<GlobalData?> globalCounter = ValueNotifier(null);
  final ValueNotifier<User?> currentUser = ValueNotifier(
    FirebaseAuth.instance.currentUser,
  );

  final _incrementController = StreamController<void>.broadcast();
  final _subscriptions = <StreamSubscription>[];
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  final _responseController = StreamController<IncrementResponse>.broadcast();

  Stream<IncrementResponse> get incrementResponseStream =>
      _responseController.stream;

  void _listenToAuth() {
    _subscriptions.add(
      FirebaseAuth.instance.authStateChanges().listen((user) {
        currentUser.value = user;
        _updateUserSubscription(user);
      }),
    );
  }

  void _updateUserSubscription(User? user) {
    _userSubscription?.cancel();
    _userSubscription = null;

    if (user == null) {
      userCounter.value = 0;
      return;
    }

    _userSubscription = FirebaseFirestore.instance
        .collection(usersCollection)
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data();
            if (data != null && data.containsKey(countField)) {
              userCounter.value = data[countField] as int;
            }
          }
        });
  }

  void _initFirestore() {
    _updateUserSubscription(FirebaseAuth.instance.currentUser);

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
  }

  Future<void> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider()..addScope('email');
      if (kDebugMode) {
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        await FirebaseAuth.instance.signInWithRedirect(googleProvider);
      }
    } catch (e) {
      print('Google sign in error: $e');
      _responseController.add(
        IncrementResponse.failure('Sign in failed. Please try again.'),
      );
    }
  }

  void increment() {
    _incrementController.add(null);
  }

  Future<void> _callIncrement() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _responseController.add(
        IncrementResponse.failure('User is not authenticated.'),
      );
      return;
    }

    final idToken = await user.getIdToken();
    if (idToken == null) {
      _responseController.add(
        IncrementResponse.failure('User is not authenticated.'),
      );
      return;
    }

    try {
      await incrementHttpsCallable.call<void>();
    } on FirebaseFunctionsException catch (e) {
      print('Error calling increment: ${e.code} ${e.message}');
      _responseController.add(IncrementResponse.failure('Error: ${e.code}'));
    }
  }

  void _handleIncrementResult(_) {
    // TODO: handle the result
  }

  void dispose() {
    _responseController.close();
    _incrementController.close();
    _userSubscription?.cancel();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
  }
}
