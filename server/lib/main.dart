import 'dart:io';

import 'package:firebase_functions/firebase_functions.dart';
import 'package:next26_shared/next26_shared.dart';

import 'src/auth_guard.dart';
import 'src/storage_fun.dart';

void main(List<String> args) async {
  final storageFun = await createStorageFun();

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

    firebase.https.onCall(name: 'increment', (request, response) async {
      final userId = await authGuard(request);
      final result = await storageFun.increment(userId);

      return CallableResult({
        'data': {
          'userCount': result.userCount,
          'totalCount': result.totalCount,
        },
      });
    });

    // Callable function with typed data using fromJson
    firebase.https.onCallWithData<GreetRequest, GreetResponse>(
      name: 'greetTyped',
      fromJson: GreetRequest.fromJson,
      (request, response) async {
        final validationErrors = await GreetRequest.validate(
          request.data.toJson(),
        );
        if (validationErrors.isNotEmpty) {
          throw RequestValidationError(
            'Invalid request data!',
            validationErrors,
          );
        }
        return GreetResponse(message: 'Hello, ${request.data.name}!');
      },
    );

    print('Functions registered successfully!');
  });
}
