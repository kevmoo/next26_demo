import 'package:firebase_functions/firebase_functions.dart';
import 'package:next26_server/src/storage_controller.dart';
import 'package:next26_shared/next26_shared.dart';

void main(List<String> args) async {
  final storageController = await createStorageController();

  await fireUp(args, (firebase) {
    firebase.https.onCall(name: $incrementCallable, (request, response) async {
      final userId =
          request.auth?.uid ??
          (throw UnauthenticatedError('User is not signed-in!'));

      await storageController.increment(userId);

      return CallableResult('success');
    });

    print('Functions registered successfully!');
  });
}
