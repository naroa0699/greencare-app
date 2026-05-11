import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final DateTime createdAt;
  final int replyCount;

  ForumPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.createdAt,
    this.replyCount = 0,
  });

  factory ForumPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ForumPost(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Usuario',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      replyCount: data['replyCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'authorId': authorId,
    'authorName': authorName,
    'title': title,
    'content': content,
    'createdAt': Timestamp.fromDate(createdAt),
    'replyCount': replyCount,
  };
}

class ForumReply {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  ForumReply({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  factory ForumReply.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ForumReply(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Usuario',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'authorId': authorId,
    'authorName': authorName,
    'content': content,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}