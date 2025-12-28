import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/mood-entry.dart';
import '../models/user_model.dart';

/// Firestore Service - Handles all database operations
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersRef => _db.collection('users');
  CollectionReference get _moodEntriesRef => _db.collection('moodEntries');
  CollectionReference get _therapistsRef => _db.collection('therapists');
  CollectionReference get _sessionsRef => _db.collection('sessions');
  CollectionReference get _communityGroupsRef =>
      _db.collection('communityGroups');
  CollectionReference get _meditationContentRef =>
      _db.collection('meditationContent');
  CollectionReference get _subscriptionsRef => _db.collection('subscriptions');

  // ==================== USER OPERATIONS ====================

  /// Create new user document
  Future<void> createUser(UserModel user) async {
    try {
      await _usersRef.doc(user.userId).set(user.toFirestore());
      debugPrint('✅ User created: ${user.userId}');
    } catch (e) {
      debugPrint('❌ Error creating user: $e');
      rethrow;
    }
  }

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user: $e');
      return null;
    }
  }

  /// Update user document
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _usersRef.doc(userId).update(data);
      debugPrint('✅ User updated: $userId');
    } catch (e) {
      debugPrint('❌ Error updating user: $e');
      rethrow;
    }
  }

  /// Delete user document
  Future<void> deleteUser(String userId) async {
    try {
      await _usersRef.doc(userId).delete();
      debugPrint('✅ User deleted: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting user: $e');
      rethrow;
    }
  }

  /// Stream user data
  Stream<UserModel?> streamUser(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // ==================== MOOD OPERATIONS ====================

  /// Create mood entry
  Future<void> createMoodEntry(MoodEntry entry) async {
    try {
      await _moodEntriesRef.doc(entry.entryId).set(entry.toFirestore());
      debugPrint('✅ Mood entry created: ${entry.entryId}');
    } catch (e) {
      debugPrint('❌ Error creating mood entry: $e');
      rethrow;
    }
  }

  /// Get mood entries for user
  Future<List<MoodEntry>> getMoodEntries(
    String userId, {
    int limit = 30,
  }) async {
    try {
      final snapshot = await _moodEntriesRef
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => MoodEntry.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ Error getting mood entries: $e');
      return [];
    }
  }

  /// Get mood entries for date range
  Future<List<MoodEntry>> getMoodEntriesForRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _moodEntriesRef
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => MoodEntry.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ Error getting mood entries for range: $e');
      return [];
    }
  }

  /// Update mood entry
  Future<void> updateMoodEntry(
    String entryId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _moodEntriesRef.doc(entryId).update(data);
      debugPrint('✅ Mood entry updated: $entryId');
    } catch (e) {
      debugPrint('❌ Error updating mood entry: $e');
      rethrow;
    }
  }

  /// Delete mood entry
  Future<void> deleteMoodEntry(String entryId) async {
    try {
      await _moodEntriesRef.doc(entryId).delete();
      debugPrint('✅ Mood entry deleted: $entryId');
    } catch (e) {
      debugPrint('❌ Error deleting mood entry: $e');
      rethrow;
    }
  }

  /// Stream mood entries
  Stream<List<MoodEntry>> streamMoodEntries(String userId, {int limit = 30}) {
    return _moodEntriesRef
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MoodEntry.fromFirestore(doc))
              .toList();
        });
  }

  // ==================== CHAT OPERATIONS ====================

  /// Save chat message
  Future<void> saveChatMessage({
    required String userId,
    required Map<String, dynamic> message,
  }) async {
    try {
      await _db
          .collection('chatMessages')
          .doc(userId)
          .collection('messages')
          .add(message);
      debugPrint('✅ Chat message saved');
    } catch (e) {
      debugPrint('❌ Error saving chat message: $e');
      rethrow;
    }
  }

  /// Get chat history
  Future<List<Map<String, dynamic>>> getChatHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _db
          .collection('chatMessages')
          .doc(userId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['messageId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting chat history: $e');
      return [];
    }
  }

  /// Delete chat history
  Future<void> deleteChatHistory(String userId) async {
    try {
      final snapshot = await _db
          .collection('chatMessages')
          .doc(userId)
          .collection('messages')
          .get();

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      debugPrint('✅ Chat history deleted');
    } catch (e) {
      debugPrint('❌ Error deleting chat history: $e');
      rethrow;
    }
  }

  /// Stream chat messages
  Stream<List<Map<String, dynamic>>> streamChatMessages(String userId) {
    return _db
        .collection('chatMessages')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['messageId'] = doc.id;
            return data;
          }).toList();
        });
  }

  // ==================== THERAPIST OPERATIONS ====================

  /// Get all therapists
  Future<List<Map<String, dynamic>>> getAllTherapists() async {
    try {
      final snapshot = await _therapistsRef
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['therapistId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting therapists: $e');
      return [];
    }
  }

  /// Get therapist by ID
  Future<Map<String, dynamic>?> getTherapist(String therapistId) async {
    try {
      final doc = await _therapistsRef.doc(therapistId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['therapistId'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting therapist: $e');
      return null;
    }
  }

  /// Search therapists by specialization
  Future<List<Map<String, dynamic>>> searchTherapists({
    String? specialization,
    double? maxPrice,
  }) async {
    try {
      Query query = _therapistsRef.where('isActive', isEqualTo: true);

      if (specialization != null) {
        query = query.where('specializations', arrayContains: specialization);
      }

      if (maxPrice != null) {
        query = query.where('pricePerSession', isLessThanOrEqualTo: maxPrice);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['therapistId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error searching therapists: $e');
      return [];
    }
  }

  // ==================== SESSION OPERATIONS ====================

  /// Create session
  Future<String> createSession(Map<String, dynamic> sessionData) async {
    try {
      final docRef = await _sessionsRef.add(sessionData);
      debugPrint('✅ Session created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating session: $e');
      rethrow;
    }
  }

  /// Get user sessions
  Future<List<Map<String, dynamic>>> getUserSessions(
    String userId, {
    String? status,
  }) async {
    try {
      Query query = _sessionsRef.where('userId', isEqualTo: userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query
          .orderBy('scheduledTime', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['sessionId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting user sessions: $e');
      return [];
    }
  }

  /// Update session
  Future<void> updateSession(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _sessionsRef.doc(sessionId).update(data);
      debugPrint('✅ Session updated: $sessionId');
    } catch (e) {
      debugPrint('❌ Error updating session: $e');
      rethrow;
    }
  }

  // ==================== COMMUNITY OPERATIONS ====================

  /// Get community groups
  Future<List<Map<String, dynamic>>> getCommunityGroups() async {
    try {
      final snapshot = await _communityGroupsRef
          .orderBy('memberCount', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['groupId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting community groups: $e');
      return [];
    }
  }

  /// Get posts for group
  Future<List<Map<String, dynamic>>> getGroupPosts(
    String groupId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _communityGroupsRef
          .doc(groupId)
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['postId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting group posts: $e');
      return [];
    }
  }

  /// Create post in group
  Future<String> createGroupPost(
    String groupId,
    Map<String, dynamic> postData,
  ) async {
    try {
      final docRef = await _communityGroupsRef
          .doc(groupId)
          .collection('posts')
          .add(postData);

      debugPrint('✅ Post created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating post: $e');
      rethrow;
    }
  }

  // ==================== MEDITATION OPERATIONS ====================

  /// Get meditation content
  Future<List<Map<String, dynamic>>> getMeditationContent({
    String? category,
  }) async {
    try {
      Query query = _meditationContentRef;

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.orderBy('title').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['contentId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting meditation content: $e');
      return [];
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Delete all user data (for account deletion)
  Future<void> deleteAllUserData(String userId) async {
    try {
      final batch = _db.batch();

      // Delete user document
      batch.delete(_usersRef.doc(userId));

      // Delete mood entries
      final moodDocs = await _moodEntriesRef
          .where('userId', isEqualTo: userId)
          .get();
      for (final doc in moodDocs.docs) {
        batch.delete(doc.reference);
      }

      // Delete chat messages
      final chatDocs = await _db
          .collection('chatMessages')
          .doc(userId)
          .collection('messages')
          .get();
      for (final doc in chatDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('✅ All user data deleted from Firestore');
    } catch (e) {
      debugPrint('❌ Error deleting user data: $e');
      rethrow;
    }
  }
}
