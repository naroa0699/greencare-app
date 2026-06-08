// Archivo generado por FlutterFire CLI. No tocar salvo que sepas lo que haces.
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyC1tZZgmviQfL7B7K8pK4x6clAcheczTEA',
    appId: '1:389405571658:web:5f9dba2fe49e14a84984b3',
    messagingSenderId: '389405571658',
    projectId: 'greencare-fd460',
    authDomain: 'greencare-fd460.firebaseapp.com',
    storageBucket: 'greencare-fd460.firebasestorage.app',
    measurementId: 'G-XCWGYHR29Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCy-X-OAcDCfZ-w7dQ9OhgBXMaVlnwb9uQ',
    appId: '1:389405571658:android:7ac1e353e3545d7a4984b3',
    messagingSenderId: '389405571658',
    projectId: 'greencare-fd460',
    storageBucket: 'greencare-fd460.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAUQSdVDGyTLT0vXThALte6NI6AsMv_-AY',
    appId: '1:389405571658:ios:e608daed1555412b4984b3',
    messagingSenderId: '389405571658',
    projectId: 'greencare-fd460',
    storageBucket: 'greencare-fd460.firebasestorage.app',
    iosClientId: '389405571658-6p8oib23828h8kggkrgr3d25b5s85m3a.apps.googleusercontent.com',
    iosBundleId: 'com.example.greencareFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC1tZZgmviQfL7B7K8pK4x6clAcheczTEA',
    appId: '1:389405571658:web:b1f6e8564b0def434984b3',
    messagingSenderId: '389405571658',
    projectId: 'greencare-fd460',
    authDomain: 'greencare-fd460.firebaseapp.com',
    storageBucket: 'greencare-fd460.firebasestorage.app',
    measurementId: 'G-R71NGY6N6K',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAUQSdVDGyTLT0vXThALte6NI6AsMv_-AY',
    appId: '1:389405571658:ios:e608daed1555412b4984b3',
    messagingSenderId: '389405571658',
    projectId: 'greencare-fd460',
    storageBucket: 'greencare-fd460.firebasestorage.app',
    iosClientId: '389405571658-6p8oib23828h8kggkrgr3d25b5s85m3a.apps.googleusercontent.com',
    iosBundleId: 'com.example.greencareFlutter',
  );

}