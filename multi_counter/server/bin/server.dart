import 'package:firebase_functions/firebase_functions.dart';
import 'package:multi_counter_server/src/storage_controller.dart';
import 'package:multi_counter_shared/multi_counter_shared.dart';

void main(List<String> args) async {
  await fireUp(args, (firebase) async {
    final storageController = StorageController(firebase.adminApp.firestore());

    Future<String> authIdFromRequest(Request request) async {
      final idToken = request.headers['Authorization']?.split(' ').last;
      if (idToken == null) {
        throw UnauthenticatedError('User is not signed-in!');
      }

      final decoded = await firebase.adminApp.auth().verifyIdToken(idToken);
      return decoded.uid;
    }

    firebase.https.onRequest(name: incrementCallable, (request) async {
      if (request.method == 'OPTIONS') {
        return Response(204, headers: _corsHeaders);
      }

      if (request.method != 'POST') {
        return Response.badRequest(body: 'Only POST requests are allowed.');
      }

      final userId = await authIdFromRequest(request);

      await storageController.increment(userId);

      return Response.ok('success', headers: _corsHeaders);
    });
  });
}

final _corsHeaders = <String, String>{
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};
