import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/forum_post_model.dart';
import '../../../data/repositories/forum_repository.dart';

class PostDetailScreen extends StatelessWidget {
  final ForumPost post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final repo = ForumRepository();
    final replyController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('Hilo')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.title,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(post.authorName,
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const Divider(height: 20),
                        Text(post.content,
                            style: const TextStyle(fontSize: 15, height: 1.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Respuestas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                StreamBuilder<List<ForumReply>>(
                  stream: repo.getReplies(post.id),
                  builder: (context, snapshot) {
                    final replies = snapshot.data ?? [];
                    if (replies.isEmpty) {
                      return const Text('Se el primero en responder.',
                          style: TextStyle(color: Colors.grey));
                    }
                    return Column(
                      children: replies.map((reply) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reply.authorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(reply.content),
                            ],
                          ),
                        ),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 12, right: 12, top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: replyController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe una respuesta...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: () async {
                    if (replyController.text.isEmpty) { return; }
                    final reply = ForumReply(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      authorId: user.uid,
                      authorName: user.email?.split('@').first ?? 'Usuario',
                      content: replyController.text.trim(),
                      createdAt: DateTime.now(),
                    );
                    await repo.addReply(post.id, reply);
                    replyController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}