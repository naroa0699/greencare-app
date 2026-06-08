import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'data/services/notification_service.dart';
import 'providers/theme_provider.dart';

void main() async {
  // Inicialización de Firebase y notificaciones.
  // Lo dejo así para el TFG: prepara todo antes de arrancar la app.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const GreenCareApp(),
    ),
  );
}
