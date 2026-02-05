import 'package:firebase_functions/firebase_functions.dart';

Future<String> authGuard(CallableRequest request) async {
  if (request.auth?.uid != null) {
    return request.auth!.uid;
  }

  throw UnauthenticatedError('User is not signed-in!');
}
