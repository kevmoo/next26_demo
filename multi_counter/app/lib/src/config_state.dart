import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_counter_shared/multi_counter_shared.dart';

import '../firebase_options.dart';

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

HttpsCallable get incrementHttpsCallable {
  if (kDebugMode) {
    return FirebaseFunctions.instance.httpsCallable(
      incrementCallable,
      options: _options,
    );
  } else {
    return FirebaseFunctions.instance.httpsCallableFromUrl(
      'https://increment-138342796561.us-central1.run.app',
      options: _options,
    );
  }
}

String get qrCodeUrl {
  if (kDebugMode) {
    final projectId = Firebase.app().options.projectId;
    return 'http://$_debugHost:$_debugFunctionsPort/$projectId/us-central1/$qrScanEndpoint';
  } else {
    return 'https://qr-scan-138342796561.us-central1.run.app/';
  }
}
