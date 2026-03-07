import 'package:firebase_functions/firebase_functions.dart';
import 'package:multi_counter_server/src/storage_controller.dart';
import 'package:multi_counter_shared/multi_counter_shared.dart';

void main(List<String> args) async {
  final storageController = await createStorageController();

  await fireUp(args, (firebase) {
    firebase.https.onCall(name: incrementCallable, (request, response) async {
      final userId =
          request.auth?.uid ??
          (throw UnauthenticatedError('User is not signed-in!'));

      await storageController.increment(userId);

      return CallableResult('success');
    });

    print('Functions registered successfully!');
  });
}
