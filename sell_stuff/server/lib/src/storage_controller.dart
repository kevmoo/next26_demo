import 'dart:convert';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
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

  StorageController._(this._firestore, this._app);

  Future<String> uploadImage(
    String base64Data,
    String mimeType,
    String fileName,
  ) async {
    final bytes = base64Decode(base64Data);
    final bucket = _app.storage().bucket();
    final object = bucket.object('listings/$fileName');
    final metadata = ObjectMetadata(contentType: mimeType);

    await object.upload(bytes, metadata: metadata);
    return await _app.storage().getDownloadURL(bucket, 'listings/$fileName');
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

  Future<void> close() async {
    await _firestore.terminate();
  }
}
