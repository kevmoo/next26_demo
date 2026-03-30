import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the options for the current platform (Web)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // await doDebug();

  runApp(const MyApp());
}
