import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:googleapis_firestore/googleapis_firestore.dart';

Future<StorageController> createStorageController() async {
  final app = FirebaseApp.initializeApp();

  return StorageController._(app.firestore());
}

typedef CounterResult = ({int userCount, int totalCount});

class StorageController {
  final Firestore _firestore;

  StorageController._(this._firestore);

  Future<CounterResult> increment(String userId) async {
    try {
      final newCount = await _firestore.runTransaction<int>((
        transaction,
      ) async {
        final ref = _firestore.collection('users').doc(userId);

        final snapshot = await transaction.get(ref);

        if (!snapshot.exists) {
          // Document doesn't exist, create it with count = 1
          transaction.set(ref, _saveCount(1));
          return 1;
        } else {
          final data = snapshot.data();
          if (data != null && data.containsKey(_countKey)) {
            // Field exists, increment it
            transaction.update(ref, {_countKey: const FieldValue.increment(1)});
            return (_parseCount(data)) + 1;
          } else {
            // Field doesn't exist, initialize it to 1
            transaction.update(ref, _saveCount(1));
            return 1;
          }
        }
      });

      final globalCountSnapshot = await _firestore
          .collection('users')
          .aggregate(const sum(_countKey))
          .get();

      var globalCountRaw = globalCountSnapshot.getSum(_countKey);

      if (globalCountRaw == null || globalCountRaw < 1) {
        // TODO: we don't want to crash here, but we should have better logging
        print('Very weird value for global count: "$globalCountRaw');
        globalCountRaw = 1;
      }

      final globalCountValue = globalCountRaw.toInt();

      final globalVars = _firestore.collection('global').doc('vars');

      // TODO: Investigate a more efficient way to do this
      // Maybe with a trigger?
      await globalVars.set({'totalCount': globalCountValue});

      return (userCount: newCount, totalCount: globalCountValue);
    } catch (e, stack) {
      print('Error incrementing counter for user: $userId');
      print(e);
      print(stack);
      rethrow;
    }
  }
}

const _countKey = 'count';

int _parseCount(Map<String, dynamic> data) {
  return data[_countKey] as int;
}

Map<String, dynamic> _saveCount(int count) {
  return {_countKey: count};
}
