import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/models/user_plant_model.dart';
import '../../../data/repositories/user_plant_repository.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late final String _userId;
  StreamSubscription? _userSub;
  StreamSubscription<List<UserPlantModel>>? _plantsSub;

  Map<String, dynamic> _userData = {};
  List<UserPlantModel> _plants = [];

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser!.uid;
    _listenToChanges();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _plantsSub?.cancel();
    super.dispose();
  }

  void _listenToChanges() {
    _userSub = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .snapshots()
        .listen((doc) {
          if (mounted) setState(() => _userData = doc.data() ?? {});
        });

    _plantsSub = UserPlantRepository().getMyPlants(_userId).listen((plants) {
      if (mounted) setState(() => _plants = plants);
    });
  }

  List<Achievement> get _achievements {
    final streak = _userData['streak'] ?? 0;
    final totalWaterings = _userData['totalWaterings'] ?? 0;
    final forumPosts = _userData['forumPosts'] ?? 0;

    return allAchievements.map((a) {
      bool unlocked = false;
      switch (a.id) {
        case 'first_plant':
          unlocked = _plants.isNotEmpty;
          break;
        case 'five_plants':
          unlocked = _plants.length >= 5;
          break;
        case 'first_water':
          unlocked = totalWaterings >= 1;
          break;
        case 'streak_3':
          unlocked = streak >= 3;
          break;
        case 'streak_7':
          unlocked = streak >= 7;
          break;
        case 'streak_30':
          unlocked = streak >= 30;
          break;
        case 'forum_post':
          unlocked = forumPosts >= 1;
          break;
      }
      return a.copyWith(unlocked: unlocked);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final achievements = _achievements;
    final unlocked = achievements.where((a) => a.unlocked).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Logros')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Text(
                  '$unlocked / ${achievements.length} logros desbloqueados',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final a = achievements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Text(
                      a.emoji,
                      style: TextStyle(
                        fontSize: 32,
                        color: a.unlocked ? null : Colors.grey,
                      ),
                    ),
                    title: Text(
                      a.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: a.unlocked ? null : Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      a.description,
                      style: TextStyle(
                        color: a.unlocked ? Colors.grey : Colors.grey.shade400,
                      ),
                    ),
                    trailing: a.unlocked
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.lock_outline, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
