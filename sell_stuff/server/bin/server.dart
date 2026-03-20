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
        throw FailedPreconditionError('Method Not Allowed');
      }

      final userId = _authIdFromRequest(request);
      if (userId == null) {
        throw UnauthenticatedError('User is not signed-in!');
      }

      final bodyStr = await request.readAsString();
      final data = jsonDecode(bodyStr) as Map<String, dynamic>;

      if (data['title'] == null || (data['title'] as String).isEmpty) {
        throw InvalidArgumentError('Title cannot be empty');
      }
      if (data['price'] == null || (data['price'] as num) <= 0) {
        throw InvalidArgumentError('Price must be greater than zero');
      }

      final validData = Map<String, dynamic>.from(data);
      validData['sellerId'] = userId;
      validData['id'] = data['id'] ?? '';
      validData['imageUrl'] = data['imageUrl'] ?? '';

      await _processImageUpload(validData, storageController);

      final listing = Listing.fromJson(validData);

      final newListing = await storageController.createListing(listing);
      return Response.ok(
        jsonEncode(newListing.toJson()),
        headers: {'content-type': 'application/json'},
      );
    });

    firebase.https.onRequest(name: editListingCallable, (request) async {
      if (request.method != 'PUT') {
        throw FailedPreconditionError('Method Not Allowed');
      }

      final userId = _authIdFromRequest(request);
      if (userId == null) {
        throw UnauthenticatedError('User is not signed-in!');
      }

      final bodyStr = await request.readAsString();
      final data = jsonDecode(bodyStr) as Map<String, dynamic>;

      if (data['title'] == null || (data['title'] as String).isEmpty) {
        throw InvalidArgumentError('Title cannot be empty');
      }
      if (data['price'] == null || (data['price'] as num) <= 0) {
        throw InvalidArgumentError('Price must be greater than zero');
      }

      final validData = Map<String, dynamic>.from(data);
      validData['sellerId'] = userId;
      validData['id'] = data['id'] ?? '';
      validData['imageUrl'] = data['imageUrl'] ?? '';

      await _processImageUpload(validData, storageController);

      final listing = Listing.fromJson(validData);

      final updatedListing = await storageController.editListing(listing);
      return Response.ok(
        jsonEncode(updatedListing.toJson()),
        headers: {'content-type': 'application/json'},
      );
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

Future<void> _processImageUpload(
  Map<String, dynamic> validData,
  StorageController storageController,
) async {
  if (validData['imageBase64'] != null &&
      (validData['imageBase64'] as String).isNotEmpty) {
    final base64String = validData['imageBase64'] as String;
    final mimeType = validData['imageMimeType'] as String? ?? 'image/jpeg';
    final originalName = validData['imageName'] as String? ?? 'image.jpg';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final name = '${timestamp}_$originalName';

    final url = await storageController.uploadImage(
      base64String,
      mimeType,
      name,
    );
    validData['imageUrl'] = url;

    validData.remove('imageBase64');
    validData.remove('imageMimeType');
    validData.remove('imageName');
  }
}
