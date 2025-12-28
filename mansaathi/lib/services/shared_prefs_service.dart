import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Shared Preferences Service - Manages app settings and simple data
class SharedPrefsService {
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  factory SharedPrefsService() => _instance;
  SharedPrefsService._internal();

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('✅ SharedPreferences ready');
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'SharedPreferences not initialized. Call initialize() first.',
      );
    }
    return _prefs!;
  }

  // ==================== USER PREFERENCES ====================

  /// Get user's preferred language
  String getLanguage() {
    return prefs.getString('user_language') ?? 'ne'; // Default Nepali
  }

  /// Set user's preferred language
  Future<bool> setLanguage(String languageCode) async {
    return await prefs.setString('user_language', languageCode);
  }

  /// Get theme mode (light/dark)
  String getThemeMode() {
    return prefs.getString('theme_mode') ?? 'light';
  }

  /// Set theme mode
  Future<bool> setThemeMode(String mode) async {
    return await prefs.setString('theme_mode', mode);
  }

  // ==================== ONBOARDING ====================

  /// Check if onboarding is completed
  bool isOnboardingCompleted() {
    return prefs.getBool('onboarding_completed') ?? false;
  }

  /// Mark onboarding as completed
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await prefs.setBool('onboarding_completed', completed);
  }

  // ==================== MOOD TRACKING ====================

  /// Get mood reminder time (hour in 24hr format)
  int getMoodReminderTime() {
    return prefs.getInt('mood_reminder_time') ?? 20; // Default 8 PM
  }

  /// Set mood reminder time
  Future<bool> setMoodReminderTime(int hour) async {
    return await prefs.setInt('mood_reminder_time', hour);
  }

  /// Get last mood check-in timestamp
  String? getLastMoodCheckIn() {
    return prefs.getString('last_mood_check_in');
  }

  /// Set last mood check-in timestamp
  Future<bool> setLastMoodCheckIn(DateTime dateTime) async {
    return await prefs.setString(
      'last_mood_check_in',
      dateTime.toIso8601String(),
    );
  }

  /// Get mood streak count
  int getStreakCount() {
    return prefs.getInt('streak_count') ?? 0;
  }

  /// Set mood streak count
  Future<bool> setStreakCount(int count) async {
    return await prefs.setInt('streak_count', count);
  }

  // ==================== NOTIFICATIONS ====================

  /// Get notification preferences
  Map<String, bool> getNotificationPreferences() {
    return {
      'moodReminder': prefs.getBool('notif_mood_reminder') ?? true,
      'sessionReminder': prefs.getBool('notif_session_reminder') ?? true,
      'communityReplies': prefs.getBool('notif_community_replies') ?? true,
      'motivationalQuotes': prefs.getBool('notif_motivational_quotes') ?? false,
      'newContent': prefs.getBool('notif_new_content') ?? true,
    };
  }

  /// Set notification preference
  Future<bool> setNotificationPreference(String key, bool value) async {
    return await prefs.setBool('notif_$key', value);
  }

  // ==================== CHAT ====================

  /// Get daily message count (for free tier limit)
  int getDailyMessageCount() {
    final lastReset = prefs.getString('message_count_last_reset');
    final today = DateTime.now();

    if (lastReset != null) {
      final lastResetDate = DateTime.parse(lastReset);
      if (today.day != lastResetDate.day ||
          today.month != lastResetDate.month ||
          today.year != lastResetDate.year) {
        // New day, reset counter
        setDailyMessageCount(0);
        return 0;
      }
    }

    return prefs.getInt('daily_message_count') ?? 0;
  }

  /// Set daily message count
  Future<bool> setDailyMessageCount(int count) async {
    await prefs.setString(
      'message_count_last_reset',
      DateTime.now().toIso8601String(),
    );
    return await prefs.setInt('daily_message_count', count);
  }

  /// Increment daily message count
  Future<void> incrementMessageCount() async {
    final current = getDailyMessageCount();
    await setDailyMessageCount(current + 1);
  }

  // ==================== MEDITATION ====================

  /// Get total meditation minutes
  int getTotalMeditationMinutes() {
    return prefs.getInt('total_meditation_minutes') ?? 0;
  }

  /// Add meditation minutes
  Future<bool> addMeditationMinutes(int minutes) async {
    final current = getTotalMeditationMinutes();
    return await prefs.setInt('total_meditation_minutes', current + minutes);
  }

  /// Get meditation streak
  int getMeditationStreak() {
    return prefs.getInt('meditation_streak') ?? 0;
  }

  /// Set meditation streak
  Future<bool> setMeditationStreak(int streak) async {
    return await prefs.setInt('meditation_streak', streak);
  }

  /// Get favorite meditation IDs
  List<String> getFavoriteMeditations() {
    return prefs.getStringList('favorite_meditations') ?? [];
  }

  /// Add favorite meditation
  Future<bool> addFavoriteMeditation(String meditationId) async {
    final favorites = getFavoriteMeditations();
    if (!favorites.contains(meditationId)) {
      favorites.add(meditationId);
      return await prefs.setStringList('favorite_meditations', favorites);
    }
    return true;
  }

  /// Remove favorite meditation
  Future<bool> removeFavoriteMeditation(String meditationId) async {
    final favorites = getFavoriteMeditations();
    favorites.remove(meditationId);
    return await prefs.setStringList('favorite_meditations', favorites);
  }

  // ==================== SUBSCRIPTION ====================

  /// Get subscription status
  String getSubscriptionStatus() {
    return prefs.getString('subscription_status') ?? 'free';
  }

  /// Set subscription status
  Future<bool> setSubscriptionStatus(String status) async {
    return await prefs.setString('subscription_status', status);
  }

  /// Get subscription expiry
  String? getSubscriptionExpiry() {
    return prefs.getString('subscription_expiry');
  }

  /// Set subscription expiry
  Future<bool> setSubscriptionExpiry(DateTime expiry) async {
    return await prefs.setString(
      'subscription_expiry',
      expiry.toIso8601String(),
    );
  }

  // ==================== USER DATA ====================

  /// Get user ID
  String? getUserId() {
    return prefs.getString('user_id');
  }

  /// Set user ID
  Future<bool> setUserId(String userId) async {
    return await prefs.setString('user_id', userId);
  }

  /// Get anonymous name
  String? getAnonymousName() {
    return prefs.getString('anonymous_name');
  }

  /// Set anonymous name
  Future<bool> setAnonymousName(String name) async {
    return await prefs.setString('anonymous_name', name);
  }

  // ==================== APP STATE ====================

  /// Check if first launch
  bool isFirstLaunch() {
    return prefs.getBool('first_launch') ?? true;
  }

  /// Mark first launch completed
  Future<bool> setFirstLaunchCompleted() async {
    return await prefs.setBool('first_launch', false);
  }

  /// Get last app version
  String? getLastAppVersion() {
    return prefs.getString('last_app_version');
  }

  /// Set last app version
  Future<bool> setLastAppVersion(String version) async {
    return await prefs.setString('last_app_version', version);
  }

  // ==================== EMERGENCY ====================

  /// Get emergency contact
  String? getEmergencyContact() {
    return prefs.getString('emergency_contact');
  }

  /// Set emergency contact
  Future<bool> setEmergencyContact(String contact) async {
    return await prefs.setString('emergency_contact', contact);
  }

  /// Get crisis plan
  String? getCrisisPlan() {
    return prefs.getString('crisis_plan');
  }

  /// Set crisis plan
  Future<bool> setCrisisPlan(String plan) async {
    return await prefs.setString('crisis_plan', plan);
  }

  // ==================== CLEAR DATA ====================

  /// Clear all preferences (for logout/account deletion)
  Future<bool> clearAll() async {
    return await prefs.clear();
  }

  /// Clear specific keys
  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  /// Clear user-specific data (keep app settings)
  Future<void> clearUserData() async {
    final keysToKeep = ['user_language', 'theme_mode', 'first_launch'];
    final allKeys = prefs.getKeys();

    for (final key in allKeys) {
      if (!keysToKeep.contains(key)) {
        await prefs.remove(key);
      }
    }
  }
}
