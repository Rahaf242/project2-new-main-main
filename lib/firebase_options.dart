// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBWSUGHoB28x91-5IR3g45c2R6BMVo1ydc',
    appId: '1:591284218054:web:1d3d2284e9d28e2e1bcfc7',
    messagingSenderId: '591284218054',
    projectId: 'myproject-db2be',
    authDomain: 'myproject-db2be.firebaseapp.com',
    storageBucket: 'myproject-db2be.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDR8hraaQZFv7VaEVWLZh7NXXpqVH6Gd1M',
    appId: '1:591284218054:android:d89f56c64d653f031bcfc7',
    messagingSenderId: '591284218054',
    projectId: 'myproject-db2be',
    storageBucket: 'myproject-db2be.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDUzVLdMZBp9tWwVgfbqZ4x7CEmAHlM7q8',
    appId: '1:591284218054:ios:7271d7da13cdc53e1bcfc7',
    messagingSenderId: '591284218054',
    projectId: 'myproject-db2be',
    storageBucket: 'myproject-db2be.appspot.com',
    iosBundleId: 'com.example.flutterInterfaces',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDUzVLdMZBp9tWwVgfbqZ4x7CEmAHlM7q8',
    appId: '1:591284218054:ios:b4bc4c24a033de9a1bcfc7',
    messagingSenderId: '591284218054',
    projectId: 'myproject-db2be',
    storageBucket: 'myproject-db2be.appspot.com',
    iosBundleId: 'com.example.flutterInterfaces.RunnerTests',
  );
}
