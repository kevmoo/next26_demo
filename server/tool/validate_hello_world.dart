#!/usr/bin/env dart

import 'dart:io' as io;

import 'package:http/http.dart' as http;

import 'tool_shared.dart';

Future<void> main() async {
  final requestUri = Uri.parse('$functionBase/helloWorld');

  print('Requesting $requestUri');

  final response = await http.get(requestUri);
  if (response.statusCode != 200) {
    print('Error: ${response.statusCode}');
    print(response.body);
    io.exitCode = 1;
    return;
  }
  print(response.body);
}
