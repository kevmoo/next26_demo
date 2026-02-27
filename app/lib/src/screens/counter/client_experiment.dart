import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:next26_shared/next26_shared.dart' as shared;

extension FirebaseFirestoreExt on FirebaseFirestore {
  UsersCollectionRef get $users =>
      UsersCollectionRef(collection(shared.$users));

  GlobalCollectionRef get $global =>
      GlobalCollectionRef(collection(shared.$global));
}

extension type UsersCollectionRef(CollectionReference<Map<String, dynamic>> ref)
    implements CollectionReference<Map<String, dynamic>> {
  DocumentReference<Map<String, dynamic>> $user(String uid) => ref.doc(uid);
}

extension type GlobalCollectionRef(
  CollectionReference<Map<String, dynamic>> ref
)
    implements CollectionReference<Map<String, dynamic>> {
  DocumentReference<Map<String, dynamic>> get $vars =>
      ref.doc(shared.$global$vars);
}

extension FirebaseFunctionsExt on FirebaseFunctions {
  HttpsCallable get $increment => httpsCallable(shared.$incrementCallable);
}
