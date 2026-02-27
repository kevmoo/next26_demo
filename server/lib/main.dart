import 'package:firebase_functions/firebase_functions.dart';
import 'package:next26_shared/next26_shared.dart';

import 'src/storage_controller.dart';

void main(List<String> args) async {
  final storageController = await createStorageController();

  await fireUp(args, (firebase) {
    firebase.https.onCall(name: incrementCallable, (request, response) async {
      final userId =
          request.auth?.uid ??
          (throw UnauthenticatedError('User is not signed-in!'));

      final result = await storageController.increment(userId);

      return CallableResult({'data': result.toJson()});
    });

    print('Functions registered successfully!');
  });
}
