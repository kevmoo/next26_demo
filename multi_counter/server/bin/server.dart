import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:firebase_functions/firebase_functions.dart';
import 'package:multi_counter_server/src/storage_controller.dart';
import 'package:multi_counter_shared/multi_counter_shared.dart';

void main(List<String> args) async {
  final storageController = await createStorageController();

  await fireUp(args, (firebase) {
    firebase.https.onRequest(name: incrementCallable, (request) async {
      final userId =
          await _authIdFromRequest(request) ??
          (throw UnauthenticatedError('User is not signed-in!'));

      await storageController.increment(userId);

      return Response.ok('success');
    });

    print('Functions registered successfully!');
  });
}

Future<String?> _authIdFromRequest(Request request) async {
  final idToken = request.headers['Authorization']?.split(' ').last;
  if (idToken == null) {
    return null;
  }

  try {
    final decoded = await _app.auth().verifyIdToken(idToken);
    print('Decoded: ${decoded.authTime} ${decoded.uid} ${decoded.email}');
    return decoded.uid;
  } catch (_) {
    return null;
  }
}

FirebaseApp get _app => __app ??= FirebaseApp.initializeApp();

FirebaseApp? __app;
