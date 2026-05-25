import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/forum_post_model.dart';
import '../../../data/repositories/forum_repository.dart';

class PostDetailScreen extends StatefulWidget {
  final ForumPost post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _repo = ForumRepository();
  final _replyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Hilo')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Post principal
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: scheme.primaryContainer,
                              child: Text(
                                widget.post.authorName
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.post.authorName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                Text(
                                  _timeAgo(widget.post.createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.post.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(color: scheme.outline.withValues(alpha: 0.3)),
                        const SizedBox(height: 8),
                        Text(
                          widget.post.content,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Cabecera respuestas
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Respuestas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Respuestas
                StreamBuilder<List<ForumReply>>(
                  stream: _repo.getReplies(widget.post.id),
                  builder: (context, snapshot) {
                    final replies = snapshot.data ?? [];
                    if (replies.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: scheme.onSurfaceVariant.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sé el primero en responder',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: replies
                          .map(
                            (reply) => _ReplyCard(
                              reply: reply,
                              postId: widget.post.id,
                              repo: _repo,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          // Caja de respuesta
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: scheme.primaryContainer,
                  child: Text(
                    (user.displayName?.isNotEmpty == true
                            ? user.displayName!
                            : user.email ?? 'U')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Escribe una respuesta...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: scheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: scheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: scheme.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isSending
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: Icon(Icons.send_rounded, color: scheme.primary),
                        onPressed: () async {
                          if (_replyController.text.isEmpty) return;
                          setState(() => _isSending = true);
                          final replyRef = _repo.newReplyRef(widget.post.id);
                          final reply = ForumReply(
                            id: replyRef.id,
                            authorId: user.uid,
                            authorName: user.displayName?.isNotEmpty == true
                                ? user.displayName!
                                : user.email?.split('@').first ?? 'Usuario',
                            content: _replyController.text.trim(),
                            createdAt: DateTime.now(),
                          );
                          await _repo.addReply(widget.post.id, reply);
                          _replyController.clear();
                          if (mounted) setState(() => _isSending = false);
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

class _ReplyCard extends StatelessWidget {
  final ForumReply reply;
  final String postId;
  final ForumRepository repo;

  const _ReplyCard({
    required this.reply,
    required this.postId,
    required this.repo,
  });

  static const _emojis = ['👍', '❤️', '🌱', '😮'];

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Autor
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: scheme.secondaryContainer,
                  child: Text(
                    reply.authorName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reply.authorName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  _timeAgo(reply.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Contenido
            Text(
              reply.content,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),

            // Reacciones
            Row(
              children: _emojis.map((emoji) {
                final users = reply.reactions[emoji] ?? [];
                final hasReacted = users.contains(userId);
                final count = users.length;

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () async {
                      await repo.toggleReplyReaction(
                        postId,
                        reply.id,
                        emoji,
                        userId,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: hasReacted
                            ? scheme.primaryContainer
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: hasReacted
                              ? scheme.primary
                              : scheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 13)),
                          if (count > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: hasReacted
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
