import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase options for supported platforms.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBay0pModFzVcZgeCXRamvmrx_OgqB5ybA',
    appId: '1:233510601464:android:576c1e966468c0433e710d',
    messagingSenderId: '233510601464',
    projectId: 'society-app-3513a',
    storageBucket: 'society-app-3513a.firebasestorage.app',
    authDomain: 'society-app-3513a.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBay0pModFzVcZgeCXRamvmrx_OgqB5ybA',
    appId: '1:233510601464:android:576c1e966468c0433e710d',
    messagingSenderId: '233510601464',
    projectId: 'society-app-3513a',
    storageBucket: 'society-app-3513a.firebasestorage.app',
  );
}
