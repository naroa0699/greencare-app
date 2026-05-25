import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_post_model.dart';

class ForumRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _posts => _db.collection('forum_posts');

  DocumentReference newPostRef() => _posts.doc();

  DocumentReference newReplyRef(String postId) =>
      _posts.doc(postId).collection('replies').doc();

  Stream<List<ForumPost>> getPosts() {
    return _posts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ForumPost.fromFirestore).toList());
  }

  Future<void> createPost(ForumPost post) async {
    final batch = _db.batch();
    batch.set(_posts.doc(post.id), post.toMap());
    batch.set(_db.collection('users').doc(post.authorId), {
      'forumPosts': FieldValue.increment(1),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  Stream<List<ForumReply>> getReplies(String postId) {
    return _posts
        .doc(postId)
        .collection('replies')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(ForumReply.fromFirestore).toList());
  }

  Future<void> addReply(String postId, ForumReply reply) async {
    final batch = _db.batch();
    final replyRef = _posts.doc(postId).collection('replies').doc(reply.id);
    batch.set(replyRef, reply.toMap());
    batch.update(_posts.doc(postId), {'replyCount': FieldValue.increment(1)});
    await batch.commit();
  }

  Future<void> toggleReaction(
    String postId,
    String emoji,
    String userId,
  ) async {
    final postRef = _posts.doc(postId);
    final doc = await postRef.get();
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawReactions = data['reactions'] as Map<String, dynamic>? ?? {};
    final users = List<String>.from(rawReactions[emoji] ?? []);

    if (users.contains(userId)) {
      users.remove(userId);
    } else {
      users.add(userId);
    }

    await postRef.update({'reactions.$emoji': users});
  }

  Future<void> toggleReplyReaction(
    String postId,
    String replyId,
    String emoji,
    String userId,
  ) async {
    final replyRef = _posts.doc(postId).collection('replies').doc(replyId);
    final doc = await replyRef.get();
    // ignore: unnecessary_cast
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawReactions =
        (data['reactions'] as Map?)?.cast<String, dynamic>() ?? {};
    final users = List<String>.from(rawReactions[emoji] ?? []);

    if (users.contains(userId)) {
      users.remove(userId);
    } else {
      users.add(userId);
    }

    await replyRef.update({'reactions.$emoji': users});
  }
}
