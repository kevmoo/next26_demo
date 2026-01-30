import 'package:firebase_functions/firebase_functions.dart';
import 'package:jose/jose.dart';

Future<String> authGuard(CallableRequest request) async {
  // if (request.auth == null) {
  //   throw UnauthenticatedError(
  //     'unauthenticated',
  //     'Authentication required!',
  //   );
  // }
  // return request.auth!.uid;

  // TODO: I'd expect auth to be populated here! Bug on the firebase bits?

  final token = switch (request.rawRequest.headers['AUTHORIZATION']?.split(
    ' ',
  )) {
    null => throw UnauthenticatedError('AUTHORIZATION header was not present!'),
    ['Bearer', final t] => JsonWebToken.unverified(t),
    _ => throw UnauthenticatedError(
      'AUTHORIZATION header was not a Bearer token!',
    ),
  };

  final userId = token.claims['user_id'] as String?;

  if (userId == null) {
    throw UnauthenticatedError('no user id in token!');
  }

  return userId;
}
