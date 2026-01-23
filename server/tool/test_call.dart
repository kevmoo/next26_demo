#!/usr/bin/env dart

import 'dart:io' as io;

import 'package:http/http.dart' as http;

Future<void> main() async {
  // For demo, defined in firebase.json
  const port = 5001;
  // For demo, defined in .firebaserc
  const projectId = 'demo-server';

  final response = await http.get(
    Uri.parse('http://localhost:$port/$projectId/us-central1/helloWorld'),
  );
  if (response.statusCode != 200) {
    print('Error: ${response.statusCode}');
    print(response.body);
    io.exitCode = 1;
    return;
  }
  print(response.body);
}
