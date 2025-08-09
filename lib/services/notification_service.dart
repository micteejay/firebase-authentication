import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'navigation_service.dart';
import 'image_navigation_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // OneSignal App ID and API Key
  static const String _appId = 'f850b4de-a705-42aa-9aa2-15370aa587b9';
  static const String _apiKey =
      'os_v2_app_bjyl6glsbvhs5ezkwszs4su5axqf2murj7iebgeau4fec3rkuvt3zxcnn2xuw2d2tutbcmrc43aznrk7eb6fgbpcfaqrwa3omnlu4uy';

  // Flutter Local Notifications
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize OneSignal
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Set log level for debugging
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      // Initialize OneSignal
      OneSignal.initialize(_appId);

      // Request notification permission
      OneSignal.Notifications.requestPermission(false);

      // Set up notification handlers
      _setupNotificationHandlers();

      // Check for initial notification (app launched from notification)
      _checkInitialNotification();

      // Set up notification click handling for app launch
      _setupNotificationClickHandling();

      print('OneSignal initialized successfully');
    } catch (e) {
      print('Error initializing OneSignal: $e');
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );
  }

  // Handle local notification tap
  void _onLocalNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // Handle local notification tap if needed
  }

  // Set up notification click handling for app launch
  void _setupNotificationClickHandling() {
    // This ensures that when the app is launched from a notification,
    // it will handle the notification data properly
    print('Setting up notification click handling for app launch...');
  }

  // Check for initial notification when app is launched
  void _checkInitialNotification() async {
    try {
      // For now, we'll just log that we're checking
      // The initial notification will be handled by the click listener
      print('Checking for initial notification...');
      print('Initial notification handling is set up via click listener');
    } catch (e) {
      print('Error checking initial notification: $e');
    }
  }

  // Set up notification event handlers
  void _setupNotificationHandlers() {
    // Handle notification clicks - this is the main handler
    OneSignal.Notifications.addClickListener((event) {
      print('Notification clicked: ${event.notification.jsonRepresentation()}');
      print('Notification data: ${event.notification.additionalData}');

      // Prevent default browser opening behavior
      event.preventDefault();

      // Handle the notification click
      _handleNotificationClick(event.notification);
    });

    // Handle foreground notifications
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print(
          'Notification will display: ${event.notification.jsonRepresentation()}');
      // You can customize how notifications appear in foreground
      event.preventDefault();
      event.notification.display();
    });

    // Handle permission changes
    OneSignal.Notifications.addPermissionObserver((state) {
      print('Notification permission changed: $state');
    });
  }

  // Handle notification click
  void _handleNotificationClick(OSNotification notification) {
    print('Handling notification click...');
    print('Notification title: ${notification.title}');
    print('Notification body: ${notification.body}');
    print('Notification data: ${notification.additionalData}');

    final data = notification.additionalData;
    if (data != null) {
      // Handle different notification types based on data
      switch (data['type']) {
        case 'profile_update':
          // Navigate to profile screen
          print('Navigate to profile');
          _navigateToProfile();
          break;
        case 'new_image':
          // Handle new image notification
          print('Navigate to new image in full screen');
          _handleNewImageNotification(data);
          break;
        case 'welcome':
          // Navigate to dashboard
          print('Navigate to dashboard');
          _navigateToDashboard();
          break;
        default:
          print('Unknown notification type: ${data['type']}');
          _navigateToDashboard();
      }
    } else {
      // Default navigation to dashboard
      print('No additional data, navigating to dashboard');
      _navigateToDashboard();
    }
  }

  // Handle new image notification
  void _handleNewImageNotification(Map<String, dynamic> data) {
    // Add a small delay to ensure the app is fully loaded
    Future.delayed(const Duration(milliseconds: 500), () {
      final imageUrl = data['image_url']?.toString();
      final filename = data['filename']?.toString() ?? 'New Image';
      final timestamp = data['timestamp']?.toString() ?? '';

      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Open the image in full screen
        ImageNavigationService().openImageInFullScreen(
          imageUrl: imageUrl,
          filename: filename,
          timestamp: timestamp,
        );
      } else {
        // Fallback to gallery if no image URL
        print('No image URL provided, navigating to gallery');
        _navigateToGallery();
      }
    });
  }

  // Navigate to profile screen
  void _navigateToProfile() {
    // Add a small delay to ensure the app is fully loaded
    Future.delayed(const Duration(milliseconds: 500), () {
      NavigationService().navigateToProfile();
    });
  }

  // Navigate to gallery/dashboard
  void _navigateToGallery() {
    // Add a small delay to ensure the app is fully loaded
    Future.delayed(const Duration(milliseconds: 500), () {
      NavigationService().navigateToGallery();
    });
  }

  // Navigate to dashboard
  void _navigateToDashboard() {
    // Add a small delay to ensure the app is fully loaded
    Future.delayed(const Duration(milliseconds: 500), () {
      NavigationService().navigateToDashboard();
    });
  }

  // Set user tags for segmentation
  Future<void> setUserTags(Map<String, String> tags) async {
    try {
      await OneSignal.User.addTags(tags);
      print('User tags set successfully: $tags');
    } catch (e) {
      print('Error setting user tags: $e');
    }
  }

  // Set user email
  Future<void> setUserEmail(String email) async {
    try {
      await OneSignal.User.addEmail(email);
      print('User email set successfully: $email');
    } catch (e) {
      print('Error setting user email: $e');
    }
  }

  // Set user ID
  Future<void> setUserId(String userId) async {
    try {
      await OneSignal.login(userId);
      print('User ID set successfully: $userId');
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await OneSignal.logout();
      print('User logged out successfully');
    } catch (e) {
      print('Error logging out user: $e');
    }
  }

  // Send notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Show in-app notification
      await _showLocalNotification(title, message, additionalData);

      print('In-app notification sent to user: $userId');
      print('Title: $title');
      print('Message: $message');
      print('Additional Data: $additionalData');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(
    String title,
    String message,
    Map<String, dynamic>? additionalData,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'intruder_cam_app',
      'Intruder Cam App',
      channelDescription: 'Notifications from Intruder Cam App',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      message,
      platformChannelSpecifics,
      payload: additionalData != null ? additionalData.toString() : null,
    );
  }

  // Send notification to all users
  Future<void> sendNotificationToAll({
    required String title,
    required String message,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Show in-app notification
      await _showLocalNotification(title, message, additionalData);

      print('In-app notification sent to all users');
      print('Title: $title');
      print('Message: $message');
      print('Additional Data: $additionalData');
    } catch (e) {
      print('Error sending notification to all users: $e');
    }
  }

  // Get device state
  Future<dynamic> getDeviceState() async {
    try {
      return await OneSignal.User.pushSubscription;
    } catch (e) {
      print('Error getting device state: $e');
      return null;
    }
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final deviceState = await getDeviceState();
      return deviceState?.pushToken != null;
    } catch (e) {
      print('Error checking notification status: $e');
      return false;
    }
  }

  // Update user profile in OneSignal
  Future<void> updateUserProfile(firebase_auth.User user) async {
    try {
      // Set user ID
      await setUserId(user.uid);

      // Set user email if available
      if (user.email != null) {
        await setUserEmail(user.email!);
      }

      // Set user tags
      final tags = <String, String>{
        'user_type': 'authenticated',
        'auth_provider': user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'email',
      };

      if (user.displayName != null) {
        tags['display_name'] = user.displayName!;
      }

      await setUserTags(tags);

      print('User profile updated successfully in OneSignal');
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  // Send welcome notification
  Future<void> sendWelcomeNotification(String userName) async {
    await sendNotificationToUser(
      userId: firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '',
      title: 'Intruder Cam App',
      message: 'Hello $userName! Welcome to Intruder Cam App.',
      additionalData: {
        'type': 'welcome',
        'user_name': userName,
      },
    );
  }

  // Send profile update notification
  Future<void> sendProfileUpdateNotification() async {
    await sendNotificationToUser(
      userId: firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '',
      title: 'Intruder Cam App',
      message: 'Your profile has been updated successfully!',
      additionalData: {
        'type': 'profile_update',
      },
    );
  }

  // Test in-app notification
  Future<void> testInAppNotification() async {
    await sendNotificationToUser(
      userId:
          firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? 'test_user',
      title: 'Intruder Cam App',
      message: 'This is a test notification from Intruder Cam App!',
      additionalData: {
        'type': 'test',
        'timestamp': DateTime.now().toString(),
      },
    );
  }

  // Send new image notification
  Future<void> sendNewImageNotification(
    String imageName, {
    String? imageUrl,
    String? timestamp,
  }) async {
    await sendNotificationToUser(
      userId: firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '',
      title: 'Intruder Cam App',
      message: 'A new image "$imageName" has been added to your gallery.',
      additionalData: {
        'type': 'new_image',
        'image_name': imageName,
        'image_url':
            imageUrl ?? 'https://intruder.micteejay.com.ng/images/$imageName',
        'filename': imageName,
        'timestamp': timestamp ?? DateTime.now().toString(),
      },
    );
  }
}
