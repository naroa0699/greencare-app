import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_themes.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _WebLayout(child: child);
    }
    return _MobileLayout(child: child);
  }
}

// ─── MOBILE ───────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final Widget child;
  const _MobileLayout({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/my-plants')) return 1;
    if (location.startsWith('/calendar')) return 2;
    if (location.startsWith('/forum')) return 3;
    if (location.startsWith('/chatbot')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/my-plants');
              break;
            case 2:
              context.go('/calendar');
              break;
            case 3:
              context.go('/forum');
              break;
            case 4:
              context.go('/chatbot');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco),
            label: 'Mis plantas',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Comunidad',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'GreenBot',
          ),
        ],
      ),
    );
  }
}

// ─── WEB ──────────────────────────────────────────────────────────────────────

class _WebLayout extends StatelessWidget {
  final Widget child;
  const _WebLayout({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/my-plants')) return 1;
    if (location.startsWith('/calendar')) return 2;
    if (location.startsWith('/forum')) return 3;
    if (location.startsWith('/chatbot')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currentIndex = _currentIndex(context);
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              border: Border(
                right: BorderSide(color: scheme.outline.withValues(alpha: 0.2)),
              ),
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                  child: Row(
                    children: [
                      Icon(Icons.eco, color: scheme.primary, size: 32),
                      const SizedBox(width: 10),
                      Text(
                        'GreenCare',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(color: scheme.outline.withValues(alpha: 0.2)),
                const SizedBox(height: 8),

                // Nav items
                _SidebarItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Inicio',
                  selected: currentIndex == 0,
                  onTap: () => context.go('/home'),
                ),
                _SidebarItem(
                  icon: Icons.eco_outlined,
                  selectedIcon: Icons.eco,
                  label: 'Mis plantas',
                  selected: currentIndex == 1,
                  onTap: () => context.go('/my-plants'),
                ),
                _SidebarItem(
                  icon: Icons.calendar_month_outlined,
                  selectedIcon: Icons.calendar_month,
                  label: 'Calendario',
                  selected: currentIndex == 2,
                  onTap: () => context.go('/calendar'),
                ),
                _SidebarItem(
                  icon: Icons.forum_outlined,
                  selectedIcon: Icons.forum,
                  label: 'Comunidad',
                  selected: currentIndex == 3,
                  onTap: () => context.go('/forum'),
                ),
                _SidebarItem(
                  icon: Icons.smart_toy_outlined,
                  selectedIcon: Icons.smart_toy,
                  label: 'GreenBot',
                  selected: currentIndex == 4,
                  onTap: () => context.go('/chatbot'),
                ),

                const Spacer(),
                Divider(color: scheme.outline.withValues(alpha: 0.2)),

                // Tema rápido
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${AppThemes.getEmoji(themeProvider.themeType)} ${AppThemes.getName(themeProvider.themeType)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          themeProvider.isDark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                        onPressed: () => themeProvider.toggleDark(),
                      ),
                    ],
                  ),
                ),

                // Perfil usuario
                InkWell(
                  onTap: () => context.push('/profile'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: scheme.primaryContainer,
                          child: Text(
                            (user?.displayName?.isNotEmpty == true
                                    ? user!.displayName!
                                    : user?.email ?? 'U')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName?.isNotEmpty == true
                                    ? user!.displayName!
                                    : user?.email?.split('@').first ??
                                          'Usuario',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: scheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                user?.email ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: scheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.settings_outlined,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: scheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getTitle(context),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: scheme.onSurfaceVariant,
                        ),
                        onPressed: () => context.push('/settings'),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.settings_outlined,
                          color: scheme.onSurfaceVariant,
                        ),
                        onPressed: () => context.push('/settings'),
                      ),
                    ],
                  ),
                ),

                // Página actual
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return '🌿 Inicio';
    if (location.startsWith('/my-plants')) return '🪴 Mis plantas';
    if (location.startsWith('/search')) return '🔍 Buscar plantas';
    if (location.startsWith('/calendar')) return '📅 Calendario';
    if (location.startsWith('/forum')) return '💬 Comunidad';
    if (location.startsWith('/chatbot')) return '🤖 GreenBot';
    if (location.startsWith('/profile')) return '👤 Mi perfil';
    if (location.startsWith('/settings')) return '⚙️ Ajustes';
    if (location.startsWith('/achievements')) return '🏆 Logros';
    return '🌿 GreenCare';
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                selected ? selectedIcon : icon,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
