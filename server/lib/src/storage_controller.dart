import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:googleapis_firestore/googleapis_firestore.dart';
import 'package:next26_shared/next26_shared.dart';

Future<StorageController> createStorageController() async {
  final app = FirebaseApp.initializeApp();

  return StorageController._(app.firestore());
}

class StorageController {
  final Firestore _firestore;

  StorageController._(this._firestore);

  Future<IncrementResponse> increment(String userId) async {
    try {
      final response = await _firestore.runTransaction<IncrementResponse>((
        transaction,
      ) async {
        final ref = _firestore.collection('users').doc(userId);

        final snapshot = await transaction.get(ref);

        if (!snapshot.exists) {
          // Document doesn't exist, create it with count = 1
          transaction.set(ref, _saveCount(1));
        } else {
          final data = snapshot.data();
          if (data != null && data.containsKey(_countKey)) {
            // Check for rate limiting

            if (data case {
              _lastIncrementKey: Timestamp(seconds: final lastSeconds),
            }) {
              final timeSinceLastIncrement =
                  Timestamp.now().seconds - lastSeconds;

              if (timeSinceLastIncrement < rateLimitSeconds) {
                // just to be mean, update the last increment time anyway
                transaction.update(ref, {
                  _lastIncrementKey: FieldValue.serverTimestamp,
                });
                return IncrementResponse.failure(
                  'You must wait $rateLimitSeconds seconds between increments.',
                );
              }
            }

            // Field exists, increment it
            transaction.update(ref, {
              _countKey: const FieldValue.increment(1),
              _lastIncrementKey: FieldValue.serverTimestamp,
            });
          } else {
            // Field doesn't exist, initialize it to 1
            transaction.update(ref, _saveCount(1));
          }
        }
        return IncrementResponse.success();
      });

      if (response.success) {
        final globalCountSnapshot = await _firestore
            .collection('users')
            .aggregate(const sum(_countKey), const count())
            .get();

        var globalCountRaw = globalCountSnapshot.getSum(_countKey);

        if (globalCountRaw == null || globalCountRaw < 1) {
          // TODO: we don't want to crash here, but we should log
          print('Very weird value for global count: "$globalCountRaw');
          globalCountRaw = 1;
        }

        final globalCountValue = globalCountRaw.toInt();
        final userCountValue = globalCountSnapshot.count;

        final globalVars = _firestore.collection('global').doc('vars');

        // TODO: Investigate a more efficient way to do this
        // Maybe with a trigger?
        await globalVars.set({
          'totalCount': globalCountValue,
          'totalUsers': userCountValue,
        });
      }

      return response;
    } catch (e, stack) {
      print('Error incrementing counter for user: $userId');
      print(e);
      print(stack);
      rethrow;
    }
  }
}

const _countKey = 'count';
const _lastIncrementKey = 'lastIncrement';

Map<String, dynamic> _saveCount(int count) {
  return {_countKey: count, _lastIncrementKey: FieldValue.serverTimestamp};
}
