import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:firebase_functions/firebase_functions.dart';
import 'package:sell_stuff_server/src/storage_controller.dart';
import 'package:sell_stuff_shared/shared.dart';

void main(List<String> args) async {
  final storageController = await createStorageController();

  await fireUp(args, (firebase) {
    firebase.https.onRequest(name: createListingCallable, (request) async {
      if (request.method != 'POST') {
        return Response(405, body: 'Method Not Allowed');
      }

      final userId = _authIdFromRequest(request);
      if (userId == null) {
        return Response(401, body: 'User is not signed-in!');
      }

      final bodyStr = await request.readAsString();
      final data = jsonDecode(bodyStr) as Map<String, dynamic>;

      if (data['title'] == null || (data['title'] as String).isEmpty) {
        return Response(400, body: 'Title cannot be empty');
      }
      if (data['price'] == null || (data['price'] as num) <= 0) {
        return Response(400, body: 'Price must be greater than zero');
      }

      final validData = Map<String, dynamic>.from(data);
      validData['sellerId'] = userId;
      final listing = Listing.fromJson(validData);

      final newListing = await storageController.createListing(listing);
      return Response.ok(
        jsonEncode(newListing.toJson()),
        headers: {'content-type': 'application/json'},
      );
    });

    firebase.https.onRequest(name: editListingCallable, (request) async {
      if (request.method != 'POST') {
        return Response(405, body: 'Method Not Allowed');
      }

      final userId = _authIdFromRequest(request);
      if (userId == null) {
        return Response(401, body: 'User is not signed-in!');
      }

      final bodyStr = await request.readAsString();
      final data = jsonDecode(bodyStr) as Map<String, dynamic>;

      if (data['title'] == null || (data['title'] as String).isEmpty) {
        return Response(400, body: 'Title cannot be empty');
      }
      if (data['price'] == null || (data['price'] as num) <= 0) {
        return Response(400, body: 'Price must be greater than zero');
      }

      final validData = Map<String, dynamic>.from(data);
      validData['sellerId'] = userId;
      final listing = Listing.fromJson(validData);

      try {
        final updatedListing = await storageController.editListing(listing);
        return Response.ok(
          jsonEncode(updatedListing.toJson()),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response(400, body: e.toString());
      }
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
