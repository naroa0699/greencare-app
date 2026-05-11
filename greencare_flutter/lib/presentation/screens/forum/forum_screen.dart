import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/forum_post_model.dart';
import '../../../data/repositories/forum_repository.dart';
import 'post_detail_screen.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ForumRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Comunidad 🌱')),
      body: StreamBuilder<List<ForumPost>>(
        stream: repo.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Se el primero en publicar algo 🌿',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            separatorBuilder: (context, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    post.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        post.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(post.authorName,
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(width: 12),
                          const Icon(Icons.comment_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${post.replyCount} respuestas',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(post: post),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewPostDialog(context, repo),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNewPostDialog(BuildContext context, ForumRepository repo) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nueva publicacion',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Titulo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Contenido',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty ||
                      contentController.text.isEmpty) { return; }

                  final post = ForumPost(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    authorId: user.uid,
                    authorName: user.email?.split('@').first ?? 'Usuario',
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    createdAt: DateTime.now(),
                  );

                  await repo.createPost(post);
                  if (ctx.mounted) { Navigator.pop(ctx); }
                },
                child: const Text('Publicar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}