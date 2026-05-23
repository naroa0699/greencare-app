import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'presentation/screens/plant_detail/plant_detail_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/search/search_screen.dart';
import 'presentation/screens/my_plants/my_plants_screen.dart';
import 'presentation/screens/calendar/calendar_screen.dart';
import 'presentation/screens/forum/forum_screen.dart';
import 'presentation/screens/forum/post_detail_screen.dart';
import 'data/models/forum_post_model.dart';
import 'presentation/screens/chatbot/chatbot_screen.dart';
import 'presentation/widgets/main_scaffold.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/achievements/achievements_screen.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final pathname = state.uri.path;

      if (!authProvider.isLoggedIn &&
          pathname != '/login' &&
          pathname != '/register') {
        return '/login';
      }
      if (authProvider.isLoggedIn &&
          (pathname == '/login' || pathname == '/register')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, _) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, _) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, _, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, _) => const HomeScreen()),
          GoRoute(
            path: '/search',
            builder: (context, _) => const SearchScreen(),
          ),
          GoRoute(
            path: '/details/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return PlantDetailScreen(plantId: id);
            },
          ),
          GoRoute(
            path: '/my-plants',
            builder: (context, _) => const MyPlantsScreen(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, _) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/forum',
            builder: (context, _) => const ForumScreen(),
            routes: [
              GoRoute(
                path: 'post',
                builder: (context, state) =>
                    PostDetailScreen(post: state.extra as ForumPost),
              ),
            ],
          ),
          GoRoute(
            path: '/chatbot',
            builder: (context, _) => const ChatbotScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, _) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/achievements',
            builder: (context, _) => const AchievementsScreen(),
          ),
        ],
      ),
    ],
  );
}

class GreenCareApp extends StatefulWidget {
  const GreenCareApp({super.key});

  @override
  State<GreenCareApp> createState() => _GreenCareAppState();
}

class _GreenCareAppState extends State<GreenCareApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _router = createRouter(_authProvider);
  }

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _authProvider,
      child: MaterialApp.router(
        title: 'GreenCare',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
          appBarTheme: const AppBarTheme(elevation: 0),
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
