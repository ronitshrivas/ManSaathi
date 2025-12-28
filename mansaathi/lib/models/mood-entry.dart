import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
  final String entryId;
  final String userId;
  final DateTime date;
  final int moodLevel; // 1-5
  final int energyLevel; // 1-10
  final int sleepQuality; // 1-5
  final List<String> triggers;
  final String? note;

  MoodEntry({
    required this.entryId,
    required this.userId,
    required this.date,
    required this.moodLevel,
    this.energyLevel = 5,
    this.sleepQuality = 3,
    this.triggers = const [],
    this.note,
  });

  // Get mood emoji
  String get moodEmoji {
    switch (moodLevel) {
      case 1:
        return '😢';
      case 2:
        return '😟';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😊';
      default:
        return '😐';
    }
  }

  // Get mood label in Nepali
  String get moodLabelNepali {
    switch (moodLevel) {
      case 1:
        return 'अति दुःखी';
      case 2:
        return 'दुःखी';
      case 3:
        return 'ठीकै छ';
      case 4:
        return 'खुसी';
      case 5:
        return 'अति खुसी';
      default:
        return 'ठीकै छ';
    }
  }

  // Get mood label in English
  String get moodLabelEnglish {
    switch (moodLevel) {
      case 1:
        return 'Very Sad';
      case 2:
        return 'Sad';
      case 3:
        return 'Okay';
      case 4:
        return 'Happy';
      case 5:
        return 'Very Happy';
      default:
        return 'Okay';
    }
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'entryId': entryId,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'moodLevel': moodLevel,
      'energyLevel': energyLevel,
      'sleepQuality': sleepQuality,
      'triggers': triggers,
      'note': note,
    };
  }

  // Create from Firestore
  factory MoodEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MoodEntry(
      entryId: data['entryId'] ?? doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      moodLevel: data['moodLevel'] ?? 3,
      energyLevel: data['energyLevel'] ?? 5,
      sleepQuality: data['sleepQuality'] ?? 3,
      triggers: List<String>.from(data['triggers'] ?? []),
      note: data['note'],
    );
  }

  // Copy with
  MoodEntry copyWith({
    String? entryId,
    String? userId,
    DateTime? date,
    int? moodLevel,
    int? energyLevel,
    int? sleepQuality,
    List<String>? triggers,
    String? note,
  }) {
    return MoodEntry(
      entryId: entryId ?? this.entryId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      moodLevel: moodLevel ?? this.moodLevel,
      energyLevel: energyLevel ?? this.energyLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      triggers: triggers ?? this.triggers,
      note: note ?? this.note,
    );
  }
}

// Mood Statistics Model
class MoodStats {
  final double averageMood;
  final double averageEnergy;
  final double averageSleep;
  final Map<String, int> triggerFrequency;
  final int totalEntries;
  final int streakDays;
  final Map<int, int> moodDistribution; // moodLevel -> count

  MoodStats({
    required this.averageMood,
    required this.averageEnergy,
    required this.averageSleep,
    required this.triggerFrequency,
    required this.totalEntries,
    required this.streakDays,
    required this.moodDistribution,
  });

  factory MoodStats.fromEntries(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return MoodStats(
        averageMood: 3.0,
        averageEnergy: 5.0,
        averageSleep: 3.0,
        triggerFrequency: {},
        totalEntries: 0,
        streakDays: 0,
        moodDistribution: {},
      );
    }

    // Calculate averages
    final avgMood =
        entries.map((e) => e.moodLevel).reduce((a, b) => a + b) /
        entries.length;
    final avgEnergy =
        entries.map((e) => e.energyLevel).reduce((a, b) => a + b) /
        entries.length;
    final avgSleep =
        entries.map((e) => e.sleepQuality).reduce((a, b) => a + b) /
        entries.length;

    // Calculate trigger frequency
    final Map<String, int> triggers = {};
    for (final entry in entries) {
      for (final trigger in entry.triggers) {
        triggers[trigger] = (triggers[trigger] ?? 0) + 1;
      }
    }

    // Calculate mood distribution
    final Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final entry in entries) {
      distribution[entry.moodLevel] = (distribution[entry.moodLevel] ?? 0) + 1;
    }

    // Calculate streak
    int streak = 0;
    entries.sort((a, b) => b.date.compareTo(a.date));
    DateTime? lastDate;

    for (final entry in entries) {
      if (lastDate == null) {
        lastDate = entry.date;
        streak = 1;
      } else {
        final diff = lastDate.difference(entry.date).inDays;
        if (diff == 1) {
          streak++;
          lastDate = entry.date;
        } else {
          break;
        }
      }
    }

    return MoodStats(
      averageMood: avgMood,
      averageEnergy: avgEnergy,
      averageSleep: avgSleep,
      triggerFrequency: triggers,
      totalEntries: entries.length,
      streakDays: streak,
      moodDistribution: distribution,
    );
  }
}
