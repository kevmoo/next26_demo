import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:firebase_functions/firebase_functions.dart';
import 'package:multi_counter_server/src/storage_controller.dart';
import 'package:multi_counter_shared/multi_counter_shared.dart';

void main(List<String> args) async {
  final storageController = await createStorageController();
  FirebaseApp? app;

  await fireUp(args, (firebase) {
    firebase.https.onRequest(name: incrementCallable, (request) async {
      app ??= FirebaseApp.initializeApp();
      final userId = await _authIdFromRequest(request, app!);

      await storageController.increment(userId);

      return Response.ok('success');
    });

    print('Functions registered successfully!');
  });
}

Future<String> _authIdFromRequest(Request request, FirebaseApp app) async {
  final idToken = request.headers['Authorization']?.split(' ').last;
  if (idToken == null) {
    throw UnauthenticatedError('User is not signed-in!');
  }

  try {
    final decoded = await app.auth().verifyIdToken(idToken);
    return decoded.uid;
  } catch (_) {
    throw UnauthenticatedError('User token not valid!');
  }
}
