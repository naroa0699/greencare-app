import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/forum_post_model.dart';
import '../../../data/repositories/forum_repository.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  ForumPost? _selectedPost;
  final _repo = ForumRepository();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (kIsWeb) {
      return _buildWebLayout(scheme);
    }
    return _buildMobileLayout(scheme);
  }

  Widget _buildMobileLayout(ColorScheme scheme) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comunidad 🌱')),
      body: _buildPostList(
        scheme,
        onTap: (post) {
          context.push('/forum/post', extra: post);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewPostDialog(context, _repo),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Nueva publicación'),
      ),
    );
  }

  Widget _buildWebLayout(ColorScheme scheme) {
    return Scaffold(
      appBar: null,
      body: Row(
        children: [
          Container(
            width: 380,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: scheme.outline.withValues(alpha: 0.2)),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Publicaciones',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => _showNewPostDialog(context, _repo),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Nueva'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildPostList(
                    scheme,
                    onTap: (post) {
                      setState(() => _selectedPost = post);
                    },
                    selectedPost: _selectedPost,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedPost == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 80,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Selecciona una publicación',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'o crea una nueva para empezar',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : _WebPostDetail(
                    post: _selectedPost!,
                    repo: _repo,
                    onClose: () => setState(() => _selectedPost = null),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostList(
    ColorScheme scheme, {
    required Function(ForumPost) onTap,
    ForumPost? selectedPost,
  }) {
    return StreamBuilder<List<ForumPost>>(
      stream: _repo.getPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 80,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  '¡Sé el primero en publicar! 🌿',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Comparte tus plantas y dudas con la comunidad',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: posts.length,
          separatorBuilder: (context, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final post = posts[index];
            final isSelected = kIsWeb && selectedPost?.id == post.id;
            return _PostCard(
              post: post,
              isSelected: isSelected,
              onTap: () => onTap(post),
            );
          },
        );
      },
    );
  }

  void _showNewPostDialog(BuildContext context, ForumRepository repo) {
    if (kIsWeb) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _NewPostForm(
                repo: repo,
                onSuccess: () => Navigator.pop(ctx),
              ),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => _NewPostSheet(repo: repo),
      );
    }
  }
}

// ─── POST CARD ────────────────────────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  final ForumPost post;
  final VoidCallback onTap;
  final bool isSelected;

  const _PostCard({
    required this.post,
    required this.onTap,
    this.isSelected = false,
  });

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

    return Card(
      clipBehavior: Clip.antiAlias,
      color: isSelected ? scheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isSelected
                        ? scheme.primary
                        : scheme.primaryContainer,
                    child: Text(
                      post.authorName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: isSelected
                            ? scheme.onPrimary
                            : scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: scheme.onSurface,
                          ),
                        ),
                        Text(
                          _timeAgo(post.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.replyCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? scheme.primary
                            : scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 12,
                            color: isSelected
                                ? scheme.onPrimary
                                : scheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.replyCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? scheme.onPrimary
                                  : scheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                post.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              _ReactionBar(
                post: post,
                onReact: (emoji) async {
                  final userId = FirebaseAuth.instance.currentUser!.uid;
                  await ForumRepository().toggleReaction(
                    post.id,
                    emoji,
                    userId,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── WEB POST DETAIL ──────────────────────────────────────────────────────────

class _WebPostDetail extends StatefulWidget {
  final ForumPost post;
  final ForumRepository repo;
  final VoidCallback onClose;

  const _WebPostDetail({
    required this.post,
    required this.repo,
    required this.onClose,
  });

  @override
  State<_WebPostDetail> createState() => _WebPostDetailState();
}

class _WebPostDetailState extends State<_WebPostDetail> {
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
    final scheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser!;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.2)),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  widget.post.authorName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
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
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                widget.post.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.post.content,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Divider(color: scheme.outline.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text(
                'Respuestas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<ForumReply>>(
                stream: widget.repo.getReplies(widget.post.id),
                builder: (context, snapshot) {
                  final replies = snapshot.data ?? [];
                  if (replies.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Sé el primero en responder',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: replies
                        .map(
                          (reply) => _WebReplyCard(
                            reply: reply,
                            postId: widget.post.id,
                            repo: widget.repo,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(
              top: BorderSide(color: scheme.outline.withValues(alpha: 0.2)),
            ),
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
              const SizedBox(width: 12),
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
                        final replyRef = widget.repo.newReplyRef(
                          widget.post.id,
                        );
                        final reply = ForumReply(
                          id: replyRef.id,
                          authorId: user.uid,
                          authorName: user.displayName?.isNotEmpty == true
                              ? user.displayName!
                              : user.email?.split('@').first ?? 'Usuario',
                          content: _replyController.text.trim(),
                          createdAt: DateTime.now(),
                        );
                        await widget.repo.addReply(widget.post.id, reply);
                        _replyController.clear();
                        if (mounted) setState(() => _isSending = false);
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── WEB REPLY CARD ───────────────────────────────────────────────────────────

class _WebReplyCard extends StatelessWidget {
  final ForumReply reply;
  final String postId;
  final ForumRepository repo;

  const _WebReplyCard({
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reply.content,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
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
                          : scheme.surface,
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
    );
  }
}

// ─── REACTION BAR ─────────────────────────────────────────────────────────────

class _ReactionBar extends StatelessWidget {
  final ForumPost post;
  final Function(String) onReact;

  const _ReactionBar({required this.post, required this.onReact});

  static const _emojis = ['👍', '❤️', '🌱', '😮'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Row(
      children: _emojis.map((emoji) {
        final users = post.reactions[emoji] ?? [];
        final hasReacted = users.contains(userId);
        final count = users.length;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onReact(emoji),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 12,
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
    );
  }
}

// ─── NEW POST SHEET (MOBILE) ──────────────────────────────────────────────────

class _NewPostSheet extends StatelessWidget {
  final ForumRepository repo;
  const _NewPostSheet({required this.repo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: _NewPostForm(repo: repo, onSuccess: () => Navigator.pop(context)),
    );
  }
}

// ─── NEW POST FORM (SHARED) ───────────────────────────────────────────────────

class _NewPostForm extends StatefulWidget {
  final ForumRepository repo;
  final VoidCallback onSuccess;

  const _NewPostForm({required this.repo, required this.onSuccess});

  @override
  State<_NewPostForm> createState() => _NewPostFormState();
}

class _NewPostFormState extends State<_NewPostForm> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!kIsWeb)
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        if (!kIsWeb) const SizedBox(height: 16),
        Text(
          '✍️ Nueva publicación',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Título',
            hintText: 'Ej: ¿Cómo cuido mi monstera?',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _contentController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Contenido',
            hintText: 'Cuéntanos más...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.edit_note),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isPosting
                ? null
                : () async {
                    if (_titleController.text.isEmpty ||
                        _contentController.text.isEmpty) {
                      return;
                    }
                    setState(() => _isPosting = true);

                    final docRef = widget.repo.newPostRef();
                    final post = ForumPost(
                      id: docRef.id,
                      authorId: user.uid,
                      authorName: user.displayName?.isNotEmpty == true
                          ? user.displayName!
                          : user.email?.split('@').first ?? 'Usuario',
                      title: _titleController.text.trim(),
                      content: _contentController.text.trim(),
                      createdAt: DateTime.now(),
                    );

                    await widget.repo.createPost(post);
                    if (mounted) widget.onSuccess();
                  },
            icon: _isPosting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_isPosting ? 'Publicando...' : 'Publicar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
