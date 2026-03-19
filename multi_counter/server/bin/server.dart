import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:firebase_functions/firebase_functions.dart';
import 'package:multi_counter_server/src/storage_controller.dart';
import 'package:multi_counter_shared/multi_counter_shared.dart';

void main(List<String> args) async {
  final storageController = await createStorageController();

  await fireUp(args, (firebase) {
    firebase.https.onRequest(name: incrementCallable, (request) async {
      final userId =
          _authIdFromRequest(request) ??
          (throw UnauthenticatedError('User is not signed-in!'));

      await storageController.increment(userId);

      return Response.ok('success');
    });

    print('Functions registered successfully!');
  });
}

String? _authIdFromRequest(Request request) {
  final idToken = request.headers['Authorization']?.split(' ').last;
  if (idToken == null) {
    return null;
  }

  Object? payload;
  try {
    payload = JWT.decode(idToken).payload;
  } catch (_) {
    return null;
  }

  return switch (payload) {
    {'user_id': final String id} => id,
    _ => null,
  };
}
