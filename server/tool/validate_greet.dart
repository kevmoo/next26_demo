#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io' as io;

import 'package:http/http.dart' as http;
import 'package:next26_shared/next26_shared.dart';

import 'tool_shared.dart';

Future<void> main() async {
  final request = GreetRequest(name: 'Kev');

  final response = await http.post(
    Uri.parse('$functionBase/greetTyped'),
    headers: {'content-type': 'application/json'},
    body: jsonEncode({'data': request.toJson()}),
  );
  if (response.statusCode != 200) {
    print('Error: ${response.statusCode}');
    print(response.body);
    io.exitCode = 1;
    return;
  }

  print(response.headers['content-type']);
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  final result = GreetResponse.fromJson(body['result'] as Map<String, dynamic>);
  print(result.message);
}
