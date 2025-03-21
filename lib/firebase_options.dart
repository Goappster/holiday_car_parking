// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBx9ZDjxR-509jtNuiQZHN95KQZ2vfZv8M',
    appId: '1:1082376010855:web:01008cc4eb5b9537c5e8c2',
    messagingSenderId: '1082376010855',
    projectId: 'holiday-car-parking',
    authDomain: 'holiday-car-parking.firebaseapp.com',
    storageBucket: 'holiday-car-parking.firebasestorage.app',
    measurementId: 'G-0BMD0JLKR2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAF7_EjOVO_QGtkCw_oZFj9bMuTb5A4oc4',
    appId: '1:1082376010855:android:bfe70c423e20a1d6c5e8c2',
    messagingSenderId: '1082376010855',
    projectId: 'holiday-car-parking',
    storageBucket: 'holiday-car-parking.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAsGiCmrDMGMjbe_rNVnb5hpylnsNLNMz4',
    appId: '1:1082376010855:ios:b534fc55e561d0c8c5e8c2',
    messagingSenderId: '1082376010855',
    projectId: 'holiday-car-parking',
    storageBucket: 'holiday-car-parking.firebasestorage.app',
    iosBundleId: 'com.holidays.car.parking.holidayscar',
  );
}
