import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../errors/exceptions.dart';
import '../../presentation/providers/notification_provider.dart';

class FirebaseService {
  final NotificationProvider _notificationProvider;
  late final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  FirebaseService(this._notificationProvider);

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;

      // Set up notification permissions
      await _requestPermissions();

      // Set up local notifications channel
      await _setupLocalNotifications();

      // Handle notifications when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification when app is opened from terminated state
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          _handleBackgroundMessage(message);
        }
      });

      // Handle notification when app is in background but not terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Set up background handlers
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Get the token
      final token = await _messaging.getToken();
      print('FCM Token: $token');

      // You would send this token to your server

    } catch (e) {
      throw ServerException('Failed to initialize Firebase: ${e.toString()}');
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        // Handle notification tap
      },
    );

    // Create high priority channel for Android
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message in foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message notification: ${message.notification!.title}, ${message.notification!.body}');
    }

    // Show local notification
    _showLocalNotification(message);

    // Update provider with the message data
    _notificationProvider.handlePushNotification(message.data);
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('Got a message in background!');
    print('Message data: ${message.data}');

    // Update provider with the message data
    _notificationProvider.handlePushNotification(message.data);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title ?? 'Новый вызов',
        notification.body ?? 'Поступил новый вызов',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            icon: android.smallIcon ?? 'ic_launcher',
            priority: Priority.max,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  // Subscribe to specific topics
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  // Unsubscribe from specific topics
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}

// This function needs to be top-level for Firebase background handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}