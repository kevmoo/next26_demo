import 'dart:convert';
import 'dart:math';
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';
import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:google_cloud_storage/google_cloud_storage.dart';
import 'package:sell_stuff_shared/shared.dart';

Future<StorageController> createStorageController() async {
  final app = FirebaseApp.initializeApp();

  return StorageController._(app.firestore(), app);
}

class StorageController {
  final Firestore _firestore;
  final FirebaseApp _app;
  final _random = Random.secure();

  StorageController._(this._firestore, this._app);

  Future<String> uploadImage(
    String base64Data,
    String mimeType,
    String userId,
  ) async {
    final randomHex = _generateRandomHex();
    final filePath =
        'listings/${DateTime.now().millisecondsSinceEpoch}_$randomHex.jpg';
    final bytes = base64Decode(base64Data);
    final bucket = _app.storage().bucket();
    final object = bucket.object(filePath);
    final metadata = ObjectMetadata(
      contentType: mimeType,
      metadata: {'userId': userId},
    );

    await object.upload(bytes, metadata: metadata);
    return await _app.storage().getDownloadURL(bucket, filePath);
  }

  Future<Listing> createListing(Listing listing) async {
    final docRef = _firestore.collection(listingsCollection).doc();
    final newListing = Listing(
      id: docRef.id,
      title: listing.title,
      description: listing.description,
      price: listing.price,
      category: listing.category,
      imageUrl: listing.imageUrl,
      sellerId: listing.sellerId,
    );
    await docRef.set(newListing.toJson());
    return newListing;
  }

  Future<Listing> editListing(Listing listing) async {
    final docRef = _firestore.collection(listingsCollection).doc(listing.id);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      throw Exception('Listing not found');
    }

    final existingData = snapshot.data();
    if (existingData?['sellerId'] != listing.sellerId) {
      throw Exception('Unauthorized edit. Seller ID mismatch.');
    }

    await docRef.update(listing.toJson());
    return listing;
  }

  String _generateRandomHex() => Iterable.generate(
    8,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();

  Future<void> close() async {
    await _firestore.terminate();
  }
}
