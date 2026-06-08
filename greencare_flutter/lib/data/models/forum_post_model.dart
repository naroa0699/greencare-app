import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelos para posts y respuestas del foro (Firestore).
/// `reactions` es un mapa emoji -> lista de userIds.
class ForumPost {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final DateTime createdAt;
  final int replyCount;
  final Map<String, List<String>> reactions; // emoji -> [userId, ...]

  ForumPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.createdAt,
    this.replyCount = 0,
    this.reactions = const {},
  });

  factory ForumPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawReactions = data['reactions'] as Map<String, dynamic>? ?? {};
    final reactions = rawReactions.map(
      (key, value) => MapEntry(key, List<String>.from(value as List)),
    );
    return ForumPost(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Usuario',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      replyCount: data['replyCount'] ?? 0,
      reactions: reactions,
    );
  }

  Map<String, dynamic> toMap() => {
    'authorId': authorId,
    'authorName': authorName,
    'title': title,
    'content': content,
    'createdAt': Timestamp.fromDate(createdAt),
    'replyCount': replyCount,
    'reactions': reactions,
  };
}

class ForumReply {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final Map<String, List<String>> reactions;

  ForumReply({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.reactions = const {},
  });

  factory ForumReply.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawReactions = data['reactions'] as Map<String, dynamic>? ?? {};
    final reactions = rawReactions.map(
      (key, value) => MapEntry(key, List<String>.from(value as List)),
    );
    return ForumReply(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Usuario',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      reactions: reactions,
    );
  }

  Map<String, dynamic> toMap() => {
    'authorId': authorId,
    'authorName': authorName,
    'content': content,
    'createdAt': Timestamp.fromDate(createdAt),
    'reactions': reactions,
  };
}
