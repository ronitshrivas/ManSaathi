import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String anonymousName;
  final DateTime createdAt;
  final String preferredLanguage;
  final List<String> areasOfConcern;
  final String subscriptionStatus; // 'free', 'premium'
  final DateTime? subscriptionExpiry;
  final String? profilePhotoPath; // Local path
  final String? emergencyContact;
  final int streakCount;
  final DateTime? lastMoodCheckIn;
  final Map<String, bool> notificationPreferences;
  final String? ageRange; // '18-25', '26-35', '36-50', '50+'
  final String? gender; // optional

  UserModel({
    required this.userId,
    required this.anonymousName,
    required this.createdAt,
    this.preferredLanguage = 'ne', // Default Nepali
    this.areasOfConcern = const [],
    this.subscriptionStatus = 'free',
    this.subscriptionExpiry,
    this.profilePhotoPath,
    this.emergencyContact,
    this.streakCount = 0,
    this.lastMoodCheckIn,
    this.notificationPreferences = const {
      'moodReminder': true,
      'sessionReminder': true,
      'communityReplies': true,
      'motivationalQuotes': false,
    },
    this.ageRange,
    this.gender,
  });

  // Check if user has premium subscription
  bool get isPremium {
    if (subscriptionStatus != 'premium') return false;
    if (subscriptionExpiry == null) return false;
    return subscriptionExpiry!.isAfter(DateTime.now());
  }

  // Check if user did mood check-in today
  bool get didMoodCheckInToday {
    if (lastMoodCheckIn == null) return false;
    final now = DateTime.now();
    final lastCheckIn = lastMoodCheckIn!;
    return now.year == lastCheckIn.year &&
        now.month == lastCheckIn.month &&
        now.day == lastCheckIn.day;
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'anonymousName': anonymousName,
      'createdAt': Timestamp.fromDate(createdAt),
      'preferredLanguage': preferredLanguage,
      'areasOfConcern': areasOfConcern,
      'subscriptionStatus': subscriptionStatus,
      'subscriptionExpiry': subscriptionExpiry != null
          ? Timestamp.fromDate(subscriptionExpiry!)
          : null,
      'profilePhotoPath': profilePhotoPath,
      'emergencyContact': emergencyContact,
      'streakCount': streakCount,
      'lastMoodCheckIn': lastMoodCheckIn != null
          ? Timestamp.fromDate(lastMoodCheckIn!)
          : null,
      'notificationPreferences': notificationPreferences,
      'ageRange': ageRange,
      'gender': gender,
    };
  }

  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      userId: data['userId'] ?? doc.id,
      anonymousName: data['anonymousName'] ?? 'Anonymous User',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferredLanguage: data['preferredLanguage'] ?? 'ne',
      areasOfConcern: List<String>.from(data['areasOfConcern'] ?? []),
      subscriptionStatus: data['subscriptionStatus'] ?? 'free',
      subscriptionExpiry: (data['subscriptionExpiry'] as Timestamp?)?.toDate(),
      profilePhotoPath: data['profilePhotoPath'],
      emergencyContact: data['emergencyContact'],
      streakCount: data['streakCount'] ?? 0,
      lastMoodCheckIn: (data['lastMoodCheckIn'] as Timestamp?)?.toDate(),
      notificationPreferences: Map<String, bool>.from(
        data['notificationPreferences'] ??
            {
              'moodReminder': true,
              'sessionReminder': true,
              'communityReplies': true,
              'motivationalQuotes': false,
            },
      ),
      ageRange: data['ageRange'],
      gender: data['gender'],
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? userId,
    String? anonymousName,
    DateTime? createdAt,
    String? preferredLanguage,
    List<String>? areasOfConcern,
    String? subscriptionStatus,
    DateTime? subscriptionExpiry,
    String? profilePhotoPath,
    String? emergencyContact,
    int? streakCount,
    DateTime? lastMoodCheckIn,
    Map<String, bool>? notificationPreferences,
    String? ageRange,
    String? gender,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      anonymousName: anonymousName ?? this.anonymousName,
      createdAt: createdAt ?? this.createdAt,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      areasOfConcern: areasOfConcern ?? this.areasOfConcern,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      streakCount: streakCount ?? this.streakCount,
      lastMoodCheckIn: lastMoodCheckIn ?? this.lastMoodCheckIn,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      ageRange: ageRange ?? this.ageRange,
      gender: gender ?? this.gender,
    );
  }
}
