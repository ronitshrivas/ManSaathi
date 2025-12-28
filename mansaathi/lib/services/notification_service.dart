import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/constants/app_constants.dart';

/// Notification Service - Handles push and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Notification permission granted');

        // Get FCM token
        _fcmToken = await _fcm.getToken();
        debugPrint('📱 FCM Token: $_fcmToken');

        // Initialize local notifications
        await _initializeLocalNotifications();

        // Setup message handlers
        _setupMessageHandlers();
      } else {
        debugPrint('❌ Notification permission denied');
      }
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    debugPrint('✅ Local notifications initialized');
  }

  /// Setup FCM message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Terminated state messages
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint(
      '📬 Foreground message received: ${message.notification?.title}',
    );

    // Show local notification when app is in foreground
    if (message.notification != null) {
      await showLocalNotification(
        title: message.notification!.title ?? 'मनसाथी',
        body: message.notification!.body ?? '',
        payload: message.data['type'],
      );
    }
  }

  /// Handle message opened app
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('📬 Notification opened: ${message.notification?.title}');

    // Navigate based on notification type
    final type = message.data['type'];
    _handleNotificationNavigation(type);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📬 Notification tapped: ${response.payload}');
    _handleNotificationNavigation(response.payload);
  }

  /// Navigate based on notification type
  void _handleNotificationNavigation(String? type) {
    // TODO: Implement navigation based on type
    // This will be connected to app router in later parts
    switch (type) {
      case AppConstants.notifTypeMoodReminder:
        debugPrint('Navigate to mood tracker');
        break;
      case AppConstants.notifTypeSessionReminder:
        debugPrint('Navigate to session');
        break;
      case AppConstants.notifTypeCommunityReply:
        debugPrint('Navigate to community');
        break;
      case AppConstants.notifTypeTherapistMessage:
        debugPrint('Navigate to messages');
        break;
      default:
        debugPrint('Navigate to home');
    }
  }

  /// Show local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'mansaathi_general',
      'General Notifications',
      channelDescription: 'General notifications from ManSaathi',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Schedule daily mood reminder
  Future<void> scheduleMoodReminder({
    required int hour,
    required int minute,
  }) async {
    // Cancel existing reminder
    await _localNotifications.cancel(1);

    const androidDetails = AndroidNotificationDetails(
      'mansaathi_mood_reminder',
      'Mood Reminders',
      channelDescription: 'Daily mood check-in reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // TODO: Implement actual scheduling with timezone plugin
    // For now, just showing as proof of concept
    debugPrint('✅ Mood reminder scheduled for $hour:$minute');
  }

  /// Schedule session reminder
  Future<void> scheduleSessionReminder({
    required DateTime sessionTime,
    required String sessionId,
    required String therapistName,
  }) async {
    final notificationTime = sessionTime.subtract(const Duration(hours: 1));

    if (notificationTime.isBefore(DateTime.now())) {
      return; // Don't schedule if time has passed
    }

    const androidDetails = AndroidNotificationDetails(
      'mansaathi_session_reminder',
      'Session Reminders',
      channelDescription: 'Therapy session reminders',
      importance: Importance.max,
      priority: Priority.max,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // TODO: Implement actual scheduling
    debugPrint('✅ Session reminder scheduled for $notificationTime');
  }

  /// Send motivational quote notification
  Future<void> sendMotivationalQuote(String quote) async {
    await showLocalNotification(
      title: 'आजको विचार 💭',
      body: quote,
      payload: 'motivational_quote',
    );
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    debugPrint('✅ All notifications cancelled');
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
    debugPrint('✅ Notification $id cancelled');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 Background message: ${message.notification?.title}');
}
