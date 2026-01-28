import 'dart:io';

import 'package:firebase_functions/firebase_functions.dart';
import 'package:next26_shared/next26_shared.dart';

void main(List<String> args) async {
  await fireUp(args, (firebase) {
    firebase.https.onRequest(
      name: 'helloWorld',
      // ignore: non_const_argument_for_const_parameter
      (request) async {
        final lines = ['hello'];

        // test!
        final entries = Platform.environment.entries
            .where((e) => e.key.startsWith('FIREBASE_'))
            .toList(growable: false);
        entries.sort((a, b) => a.key.compareTo(b.key));

        for (var entry in entries) {
          lines.add('${entry.key}. ${entry.value}');
        }

        // Access parameter value at runtime
        return Response.ok(lines.join('\n'));
      },
    );

    // Callable function with typed data using fromJson
    firebase.https.onCallWithData<GreetRequest, GreetResponse>(
      name: 'greetTyped',
      fromJson: GreetRequest.fromJson,
      (request, response) async {
        return GreetResponse(message: 'Hello, ${request.data.name}!');
      },
    );

    print('Functions registered successfully!');
  });
}
