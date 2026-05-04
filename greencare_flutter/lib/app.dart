import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

// TODO: organizar imports cuando sea necesario

import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/search/search_screen.dart';
import 'presentation/screens/my_plants/my_plants_screen.dart';
import 'presentation/screens/calendar/calendar_screen.dart';
import 'presentation/screens/forum/forum_screen.dart';
import 'presentation/screens/chatbot/chatbot_screen.dart';
import 'presentation/widgets/main_scaffold.dart';

// Configurar rutas globales
final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final user = context.read<AuthProvider>();
    final pathname = state.uri.path;
    
    if (!user.isLoggedIn && pathname != '/login' && pathname != '/register') {
      return '/login';
    }
    
    if (user.isLoggedIn && (pathname == '/login' || pathname == '/register')) {
      return '/home';
    }
    
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterScreen(),
    ),
    ShellRoute(
      builder: (_, __, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (_, __) => const SearchScreen(),
        ),
        GoRoute(
          path: '/my-plants',
          builder: (_, __) => const MyPlantsScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (_, __) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/forum',
          builder: (_, __) => const ForumScreen(),
        ),
        GoRoute(
          path: '/chatbot',
          builder: (_, __) => const ChatbotScreen(),
        ),
      ],
    ),
  ],
);

class GreenCareApp extends StatelessWidget {
  const GreenCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // TODO: agregar plant provider y forum provider
      ],
      child: MaterialApp.router(
        title: 'GreenCare',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
          ),
        ),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}