import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_counter_shared/multi_counter_shared.dart';

import '../firebase_options.dart';
import 'constants.dart';

const _debugHost = '127.0.0.1';
const _debugFunctionsPort = 5001;

Future<void> initializeWorld() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator(_debugHost, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(_debugHost, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(
      _debugHost,
      _debugFunctionsPort,
    );
  }
}

final _options = HttpsCallableOptions(timeout: const Duration(seconds: 15));

HttpsCallable get incrementHttpsCallable => FirebaseFunctions.instance
    .httpsCallableFromUrl(_functionUrl(incrementCallable), options: _options);

String get qrCodeUrl => _functionUrl(qrScanEndpoint);

/// Base URL for remote functions.
String _functionUrl(String name) {
  if (kDebugMode) {
    final projectId = Firebase.app().options.projectId;
    return 'http://$_debugHost:$_debugFunctionsPort/$projectId/$region/$name';
  } else {
    return 'https://$name-$projectNumber.$region.run.app';
  }
}
