import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  runApp(const SellStuffApp());
}
