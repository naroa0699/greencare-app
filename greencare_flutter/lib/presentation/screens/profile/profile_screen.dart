import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/repositories/user_plant_repository.dart';
import '../../../data/models/user_plant_model.dart';
import '../../../providers/auth_provider.dart' as app_auth;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _displayNameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _displayNameController.text =
        user?.displayName ?? user?.email?.split('@').first ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _saveDisplayName() async {
    await FirebaseAuth.instance.currentUser?.updateDisplayName(
      _displayNameController.text.trim(),
    );
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    await context.read<app_auth.AuthProvider>().reloadUser();
    if (!mounted) return;
    setState(() => _isEditing = false);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nombre actualizado ✅')));
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Seguro que quieres eliminar tu cuenta? Esta acción no se puede deshacer y perderás todas tus plantas y datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      await user.delete();
      if (mounted) {
        await context.read<AuthProvider>().signOut();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Por seguridad debes volver a iniciar sesión antes de eliminar tu cuenta.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final repo = UserPlantRepository();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundColor: scheme.primary,
              child: Text(
                (user.displayName?.isNotEmpty == true
                        ? user.displayName!
                        : user.email ?? 'U')
                    .substring(0, 1)
                    .toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _isEditing
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            border: OutlineInputBorder(),
                          ),
                          autofocus: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: _saveDisplayName,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() => _isEditing = false),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.displayName?.isNotEmpty == true
                            ? user.displayName!
                            : user.email?.split('@').first ?? 'Usuario',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _isEditing = true),
                      ),
                    ],
                  ),

            Text(user.email ?? '', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),

            // Estadísticas
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots(),
              builder: (context, userSnapshot) {
                final userData =
                    userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                final streak = userData['streak'] ?? 0;

                return StreamBuilder<List<UserPlantModel>>(
                  stream: repo.getMyPlants(userId),
                  builder: (context, snapshot) {
                    final plants = snapshot.data ?? [];
                    final urgent = plants
                        .where(
                          (p) =>
                              p.nextWatering
                                  .difference(DateTime.now())
                                  .inDays <=
                              0,
                        )
                        .length;

                    return Row(
                      children: [
                        _StatCard(
                          icon: Icons.eco,
                          label: 'Plantas',
                          value: '${plants.length}',
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 8),
                        _StatCard(
                          icon: Icons.water_drop,
                          label: 'Pendientes',
                          value: '$urgent',
                          color: scheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        _StatCard(
                          icon: Icons.local_fire_department,
                          label: 'Racha',
                          value: '$streak 🔥',
                          color: scheme.tertiary,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            _OptionTile(
              icon: Icons.settings_outlined,
              label: 'Ajustes',
              onTap: () => context.push('/settings'),
            ),
            _OptionTile(
              icon: Icons.emoji_events_outlined,
              label: 'Mis logros',
              onTap: () => context.push('/achievements'),
            ),
            _OptionTile(
              icon: Icons.lock_outline,
              label: 'Cambiar contraseña',
              onTap: () async {
                final email = user.email;
                if (email != null) {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Email de restablecimiento enviado a $email',
                      ),
                    ),
                  );
                }
              },
            ),
            _OptionTile(
              icon: Icons.info_outline,
              label: 'Acerca de GreenCare',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'GreenCare',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 Naroa Marco',
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Aplicacion movil para el cuidado inteligente de plantas.',
                  ),
                ],
              ),
            ),
            _OptionTile(
              icon: Icons.delete_forever_outlined,
              label: 'Eliminar cuenta',
              onTap: _deleteAccount,
              iconColor: Colors.red,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Cerrar sesion',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
        ),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
