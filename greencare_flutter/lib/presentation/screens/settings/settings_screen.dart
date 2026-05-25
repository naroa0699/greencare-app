import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../core/theme/app_themes.dart';
import '../../../data/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección apariencia
          _SectionHeader(title: '🎨 Apariencia', scheme: scheme),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Modo oscuro'),
                  subtitle: const Text('Cambia el tema de la app'),
                  secondary: Icon(
                    themeProvider.isDark
                        ? Icons.dark_mode
                        : Icons.light_mode_outlined,
                    color: scheme.primary,
                  ),
                  value: themeProvider.isDark,
                  onChanged: (_) => themeProvider.toggleDark(),
                ),
                Divider(
                  height: 1,
                  color: scheme.outline.withValues(alpha: 0.2),
                ),
                ListTile(
                  leading: Icon(Icons.palette_outlined, color: scheme.primary),
                  title: const Text('Paleta de colores'),
                  subtitle: Text(
                    '${AppThemes.getEmoji(themeProvider.themeType)} ${AppThemes.getName(themeProvider.themeType)}',
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: scheme.onSurfaceVariant,
                  ),
                  onTap: () => _showThemeSelector(context, themeProvider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sección notificaciones
          _SectionHeader(title: '🔔 Notificaciones', scheme: scheme),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Recordatorios de riego'),
                  subtitle: const Text(
                    'Recibe avisos cuando tus plantas necesiten agua',
                  ),
                  secondary: Icon(
                    Icons.water_drop_outlined,
                    color: scheme.primary,
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) =>
                      setState(() => _notificationsEnabled = value),
                ),
                Divider(
                  height: 1,
                  color: scheme.outline.withValues(alpha: 0.2),
                ),
                ListTile(
                  leading: Icon(Icons.schedule, color: scheme.primary),
                  title: const Text('Hora del recordatorio'),
                  subtitle: Text(
                    '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: scheme.onSurfaceVariant,
                  ),
                  onTap: _notificationsEnabled
                      ? () => _pickTime(context)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sección demo
          _SectionHeader(title: '🧪 Demo', scheme: scheme),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.notifications_active_outlined,
                color: scheme.primary,
              ),
              title: const Text('Probar notificación'),
              subtitle: const Text(
                'Envía una notificación de prueba en 10 segundos',
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: scheme.onSurfaceVariant,
              ),
              onTap: () => _testNotification(context),
            ),
          ),
          const SizedBox(height: 20),

          // Sección acerca de
          _SectionHeader(title: 'ℹ️ Acerca de', scheme: scheme),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.eco, color: scheme.primary),
                  title: const Text('GreenCare'),
                  subtitle: const Text('Versión 1.0.0'),
                ),
                Divider(
                  height: 1,
                  color: scheme.outline.withValues(alpha: 0.2),
                ),
                ListTile(
                  leading: Icon(Icons.person_outline, color: scheme.primary),
                  title: const Text('Desarrollada por'),
                  subtitle: const Text('Naroa Marco — TFG 2026'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recordatorio configurado a las ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} ⏰',
            ),
          ),
        );
      }
    }
  }

  Future<void> _testNotification(BuildContext context) async {
    await NotificationService().scheduleWateringNotification(
      id: 999,
      plantName: 'Aloe Vera',
      scheduledDate: DateTime.now().add(const Duration(seconds: 10)),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación de prueba en 10 segundos 🔔'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Elige tu tema',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...AppThemeType.values.map((type) {
                final isSelected = themeProvider.themeType == type;
                return ListTile(
                  leading: Text(
                    AppThemes.getEmoji(type),
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(AppThemes.getName(type)),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    themeProvider.setTheme(type);
                    setModalState(() {});
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ColorScheme scheme;

  const _SectionHeader({required this.title, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: scheme.primary,
        ),
      ),
    );
  }
}
