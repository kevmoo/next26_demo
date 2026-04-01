import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

Future<void> initializeWorld() async {
  final options = DefaultFirebaseOptions.currentPlatform;
  final debugOptions = FirebaseOptions(
    apiKey: options.apiKey,
    appId: options.appId,
    messagingSenderId: options.messagingSenderId,
    projectId: 'demo-server',
    authDomain: options.authDomain,
    databaseURL: options.databaseURL,
    storageBucket: options.storageBucket,
    measurementId: options.measurementId,
  );

  await Firebase.initializeApp(options: kDebugMode ? debugOptions : options);

  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  }
}

Uri get incrementUri {
  if (kDebugMode) {
    return Uri.parse('http://127.0.0.1:5001/demo-server/us-central1/increment');
  } else {
    return Uri.parse('https://increment-ruyjilv5wq-uc.a.run.app');
  }
}
