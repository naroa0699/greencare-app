import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/repositories/user_plant_repository.dart';
import '../../../data/models/user_plant_model.dart';

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
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre actualizado ✅')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final repo = UserPlantRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF4CAF50),
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

            // Nombre editable
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
            StreamBuilder<List<UserPlantModel>>(
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
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.water_drop,
                      label: 'Riegos pendientes',
                      value: '$urgent',
                      color: Colors.blue,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Opciones
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
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: email);
                  if (!context.mounted) { return; }
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4CAF50)),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}