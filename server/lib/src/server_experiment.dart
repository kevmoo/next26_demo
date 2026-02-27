import 'package:google_cloud_firestore/google_cloud_firestore.dart';

import 'package:next26_shared/next26_shared.dart' as shared;

extension FirebaseFirestoreExt on Firestore {
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
