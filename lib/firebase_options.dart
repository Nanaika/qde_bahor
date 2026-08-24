import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA2OXozmSv34Kj7GA_gMCHAfpOEhFuY0f8',
    appId: '1:671291937915:web:f558c80ab694bb535fbede',
    messagingSenderId: '671291937915',
    projectId: 'ecobahor-99ca6',
    authDomain: 'ecobahor-99ca6.firebaseapp.com',
    storageBucket: 'ecobahor-99ca6.firebasestorage.app',
    measurementId: 'G-H4QG304Z6L',
  );

}