import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:multi_counter_shared/multi_counter_shared.dart';

Future<void> updateGlobalCount(Firestore firestore) async {
  try {
    final globalCountSnapshot = await firestore
        .collection(usersCollection)
        .aggregate(const sum(countField), const count())
        .get();

    var globalCountRaw = globalCountSnapshot.getSum(countField);

    if (globalCountRaw == null || globalCountRaw < 1) {
      print('Very weird value for global count: "$globalCountRaw');
      globalCountRaw = 1;
    }

    final globalCountValue = globalCountRaw.toInt();
    final userCountValue = globalCountSnapshot.count;

    final globalVars = firestore.collection(globalCollection).doc(varsDocument);

    final currentData = (await globalVars.get()).data() ?? <String, dynamic>{};

    await globalVars.set({
      ...currentData,
      totalCountField: globalCountValue,
      totalUsersField: userCountValue,
    });
  } catch (e, stack) {
    print('Error updating global counts: $e');
    print(stack);
  }
}
