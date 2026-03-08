import 'package:firebase_functions/firebase_functions.dart';
import 'package:sell_stuff_server/src/storage_controller.dart';
import 'package:sell_stuff_shared/shared.dart';

void main(List<String> args) async {
  final storageController = await createStorageController();

  await fireUp(args, (firebase) {
    firebase.https.onCall(name: createListingCallable, (
      request,
      response,
    ) async {
      final userId = request.auth?.uid;
      if (userId == null) {
        throw UnauthenticatedError('User is not signed-in!');
      }

      final data = request.data as Map<String, dynamic>;

      if (data['title'] == null || (data['title'] as String).isEmpty) {
        throw InvalidArgumentError('Title cannot be empty');
      }
      if (data['price'] == null || (data['price'] as num) <= 0) {
        throw InvalidArgumentError('Price must be greater than zero');
      }

      final validData = Map<String, dynamic>.from(data);
      validData['sellerId'] = userId;
      final listing = Listing.fromJson(validData);

      final newListing = await storageController.createListing(listing);
      return CallableResult(newListing.toJson());
    });

    firebase.https.onCall(name: editListingCallable, (request, response) async {
      final userId = request.auth?.uid;
      if (userId == null) {
        throw UnauthenticatedError('User is not signed-in!');
      }

      final data = request.data as Map<String, dynamic>;

      if (data['title'] == null || (data['title'] as String).isEmpty) {
        throw InvalidArgumentError('Title cannot be empty');
      }
      if (data['price'] == null || (data['price'] as num) <= 0) {
        throw InvalidArgumentError('Price must be greater than zero');
      }

      final validData = Map<String, dynamic>.from(data);
      validData['sellerId'] = userId;
      final listing = Listing.fromJson(validData);

      try {
        final updatedListing = await storageController.editListing(listing);
        return CallableResult(updatedListing.toJson());
      } catch (e) {
        throw FailedPreconditionError(e.toString());
      }
    });

    print('Functions registered successfully!');
  });
}
