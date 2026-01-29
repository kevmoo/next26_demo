import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:googleapis_firestore/googleapis_firestore.dart';

Future<StorageFun> createStorageFun() async {
  final app = FirebaseApp.initializeApp();

  return StorageFun(app.firestore());
}

class StorageFun {
  final Firestore _firestore;

  StorageFun(this._firestore);

  Future<({int userCount, int totalCount})> increment(String userId) async {
    try {
      final newCount = await _firestore.runTransaction<int>((
        transaction,
      ) async {
        final ref = _firestore.collection('users').doc(userId);

        final snapshot = await transaction.get(ref);

        if (!snapshot.exists) {
          // Document doesn't exist, create it with count = 1
          transaction.set(ref, {'count': 1});
          return 1;
        } else {
          final data = snapshot.data();
          if (data != null && data.containsKey('count')) {
            // Field exists, increment it
            transaction.update(ref, {'count': const FieldValue.increment(1)});
            return (data['count'] as int) + 1;
          } else {
            // Field doesn't exist, initialize it to 1
            transaction.update(ref, {'count': 1});
            return 1;
          }
        }
      });

      final result = await _firestore
          .collection('users')
          .aggregate(const sum('count'))
          .get();

      return (userCount: newCount, totalCount: result.getSum('count')! as int);
    } catch (e, stack) {
      print('Error incrementing counter for user: $userId');
      print(e);
      print(stack);
      rethrow;
    }
  }
}
