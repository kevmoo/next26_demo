import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sell_stuff_shared/shared.dart';

class NewItemState {
  String title = '';
  String description = '';
  String priceString = '';
  String category = '';
  XFile? selectedImage;

  Future<void> submit() async {
    final price = double.tryParse(priceString);
    if (price == null || price <= 0) {
      throw Exception('Invalid price');
    }

    var imageBase64 = '';
    var imageMimeType = '';
    if (selectedImage != null) {
      final bytes = await selectedImage!.readAsBytes();
      imageBase64 = base64Encode(bytes);
      imageMimeType = selectedImage!.mimeType ?? 'image/jpeg';
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not signed in.');
    }
    final idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to get auth token.');
    }

    final options = Firebase.app().options;
    final projectId = options.projectId;

    late Uri uri;
    if (kDebugMode) {
      uri = Uri.parse(
        'http://localhost:5001/$projectId/us-central1/$createListingCallable',
      );
    } else {
      uri = Uri.parse(
        'https://us-central1-$projectId.cloudfunctions.net/$createListingCallable',
      );
    }

    final createRequest = CreateListingRequest(
      title: title,
      description: description,
      price: price,
      category: category,
      imageBase64: imageBase64,
      imageMimeType: imageMimeType,
    );

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(createRequest.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to create listing: '
        '${response.statusCode} ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>?> requestSuggestions() async {
    if (selectedImage == null) return null;

    final bytes = await selectedImage!.readAsBytes();
    final imageBase64 = base64Encode(bytes);
    final imageMimeType = selectedImage!.mimeType ?? 'image/jpeg';

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not signed in.');
    }
    final idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to get auth token.');
    }

    final options = Firebase.app().options;
    final projectId = options.projectId;

    late Uri uri;
    if (kDebugMode) {
      uri = Uri.parse(
        'http://localhost:5001/$projectId/us-central1/$suggestionDetailsCallable',
      );
    } else {
      uri = Uri.parse(
        'https://us-central1-$projectId.cloudfunctions.net/$suggestionDetailsCallable',
      );
    }

    final abortCompleter = Completer<void>();
    final client = http.Client();
    try {
      final request =
          http.AbortableRequest(
              'POST',
              uri,
              abortTrigger: abortCompleter.future,
            )
            ..headers.addAll({
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
            })
            ..body = jsonEncode({
              'imageBase64': imageBase64,
              'imageMimeType': imageMimeType,
            });

      final streamedResponse = await client
          .send(request)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              if (!abortCompleter.isCompleted) {
                abortCompleter.complete();
              }
              throw Exception('Request timed out');
            },
          );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to get suggestions: '
          '${response.statusCode} ${response.body}',
        );
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }
}
