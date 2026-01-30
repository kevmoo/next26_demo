import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:googleapis_firestore/googleapis_firestore.dart';

Future<StorageFun> createStorageFun() async {
  final app = FirebaseApp.initializeApp();

  return StorageFun(app.firestore());
}

typedef CounterResult = ({int userCount, int totalCount});

class StorageFun {
  final Firestore _firestore;

  StorageFun(this._firestore);

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

      final result = await _firestore
          .collection('users')
          .aggregate(const sum(_countKey))
          .get();

      return (
        userCount: newCount,
        totalCount: (result.getSum(_countKey) ?? 0).toInt(),
      );
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
