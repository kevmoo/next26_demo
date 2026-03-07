import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD-BEnanZopAMupeec6imGUfiIr_xMRsIg',
    appId: '1:915141274861:web:5a1fafe7914423853930e4',
    messagingSenderId: '915141274861',
    projectId: 'demo-server',
    authDomain: 'j832-com.firebaseapp.com',
    databaseURL: 'https://j832-com.firebaseio.com',
    storageBucket: 'j832-com.firebasestorage.app',
    measurementId: 'G-2CD5ZN35E8',
  );
}
