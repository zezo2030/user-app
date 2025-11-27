import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../firebase_options.dart';
import '../constants/api_constants.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage_service.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('📱 Background message received: ${message.messageId}');
  debugPrint('📱 Title: ${message.notification?.title}');
  debugPrint('📱 Body: ${message.notification?.body}');
  debugPrint('📱 Data: ${message.data}');
  
  // Initialize and show local notification for background messages
  try {
    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
    
    // Initialize Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await localNotifications.initialize(initSettings);
    
    // Create notification channel for Android if needed
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: true,
      );
      await localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
    
    // Show notification if message has notification payload
    final notification = message.notification;
    if (notification != null) {
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await localNotifications.show(
        message.hashCode,
        notification.title ?? 'تنبيه',
        notification.body ?? '',
        notificationDetails,
        payload: message.data.toString(),
      );
      
      debugPrint('✅ Background notification displayed: ${notification.title}');
    }
  } catch (e) {
    debugPrint('❌ Failed to show background notification: $e');
  }
}

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  FirebaseMessaging? _messaging;
  FlutterLocalNotificationsPlugin? _localNotifications;
  String? _fcmToken;
  bool _initialized = false;

  /// Initialize Firebase
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('✅ Firebase already initialized');
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _messaging = FirebaseMessaging.instance;

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      await _requestPermissions();

      // Get FCM token
      await _getFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      _initialized = true;
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications!.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('📱 Local notification tapped: ${response.payload}');
        // Handle notification tap if needed
      },
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // name
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications!
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }

    debugPrint('✅ Local notifications initialized');
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('📱 iOS Notification permission status: ${settings.authorizationStatus}');
    } else if (Platform.isAndroid) {
      // Android 13+ (API 33+) requires runtime permission for POST_NOTIFICATIONS
      // On Android 12 and below, this will return granted automatically
      try {
        final status = await Permission.notification.status;
        debugPrint('📱 Android notification permission status: $status');
        
        if (status.isDenied) {
          debugPrint('📱 Requesting Android notification permission...');
          final result = await Permission.notification.request();
          debugPrint('📱 Android notification permission request result: $result');
          
          if (result.isGranted) {
            debugPrint('✅ Android notification permission granted');
          } else if (result.isPermanentlyDenied) {
            debugPrint('⚠️ Android notification permission permanently denied - user needs to enable from settings');
            debugPrint('💡 You can open app settings to enable notifications manually');
          } else {
            debugPrint('❌ Android notification permission denied');
          }
        } else if (status.isGranted) {
          debugPrint('✅ Android notification permission already granted');
        } else if (status.isPermanentlyDenied) {
          debugPrint('⚠️ Android notification permission permanently denied - user needs to enable from settings');
        } else if (status.isLimited) {
          debugPrint('📱 Android notification permission limited (partial access)');
        }
      } catch (e) {
        debugPrint('❌ Error requesting Android notification permission: $e');
        // Continue anyway - some Android versions handle permissions differently
        debugPrint('📱 Continuing with notification setup...');
      }
    }
  }

  /// Get FCM token
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _messaging!.getToken();
      debugPrint('📱 FCM Token: $_fcmToken');
      
      // Register token with backend
      await _registerTokenWithBackend(_fcmToken!);
      
      // Listen for token refresh
      _messaging!.onTokenRefresh.listen((newToken) {
        debugPrint('📱 FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        _registerTokenWithBackend(newToken);
      });

      return _fcmToken;
    } catch (e) {
      debugPrint('❌ Failed to get FCM token: $e');
      return null;
    }
  }

  /// Register FCM token with backend
  Future<void> _registerTokenWithBackend(String token) async {
    try {
      String? userId;
      try {
        final userDataStr = await SecureStorageService().getUserData();
        if (userDataStr != null) {
          final userData = jsonDecode(userDataStr) as Map<String, dynamic>;
          userId = userData['id'] as String?;
        }
      } catch (e) {
        debugPrint('⚠️ Failed to parse user data: $e');
        // Continue without userId
      }

      final platform = Platform.isIOS ? 'ios' : 'android';
      
      debugPrint('🔄 Registering device token (UserId: ${userId ?? "None"})...');

      await DioClient.instance.post(
        '${ApiConstants.baseUrl}/notifications/register-device',
        data: {
          'userId': userId, // Can be null now
          'token': token,
          'platform': platform,
        },
      );

      debugPrint('✅ FCM token registered with backend successfully');
    } catch (e) {
      debugPrint('❌ Failed to register FCM token: $e');
    }
  }

  /// Re-register token if user is logged in (call this after login)
  Future<void> registerTokenIfUserLoggedIn() async {
    if (_fcmToken == null) {
      debugPrint('⚠️ No FCM token available - attempting to get token');
      await _getFCMToken();
      return;
    }
    
    debugPrint('🔄 Attempting to re-register FCM token after login...');
    await _registerTokenWithBackend(_fcmToken!);
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('📱 Foreground message received: ${message.messageId}');
      debugPrint('📱 Title: ${message.notification?.title}');
      debugPrint('📱 Body: ${message.notification?.body}');
      debugPrint('📱 Data: ${message.data}');
      
      // Handle notification here (show local notification, update UI, etc.)
      await _handleNotification(message);
    });

    // Background messages (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📱 App opened from background notification: ${message.messageId}');
      _handleNotificationTap(message);
    });

    // Check if app was opened from terminated state
    _messaging!.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('📱 App opened from terminated state: ${message.messageId}');
        _handleNotificationTap(message);
      }
    });
  }

  /// Handle notification
  Future<void> _handleNotification(RemoteMessage message) async {
    debugPrint('📱 Handling notification: ${message.data}');
    
    // Show local notification when app is in foreground
    final notification = message.notification;
    if (notification != null && _localNotifications != null) {
      final title = notification.title ?? 'تنبيه';
      final body = notification.body ?? '';
      
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      try {
        await _localNotifications!.show(
          message.hashCode, // Use message hash as notification ID
          title,
          body,
          notificationDetails,
          payload: jsonEncode(message.data),
        );
        debugPrint('✅ Local notification displayed: $title');
      } catch (e) {
        debugPrint('❌ Failed to show local notification: $e');
      }
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    
    debugPrint('📱 Notification tapped - Type: $type, Data: $data');
    
    // Navigate based on notification type
    // Example: if type is 'BOOKING_CONFIRMED', navigate to booking details
    // This should be handled by your navigation service
  }

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Unregister device token
  Future<void> unregisterDevice() async {
    if (_fcmToken == null) return;

    try {
      await DioClient.instance.delete(
        '${ApiConstants.baseUrl}/notifications/unregister-device',
        data: {'token': _fcmToken},
      );
      debugPrint('✅ Device unregistered successfully');
    } catch (e) {
      debugPrint('❌ Failed to unregister device: $e');
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging!.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Failed to subscribe to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging!.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Failed to unsubscribe from topic: $e');
    }
  }
}
